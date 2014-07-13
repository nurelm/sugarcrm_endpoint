require 'json'

class Sugarcrm
  CLIENT_ID = "sugar"
  CLIENT_SECRET = ""
  BASE_API_URI = "/rest/v10"

  attr_accessor :order, :config, :payload, :request

  def initialize(payload, config={})
    @payload = payload
    @config = config
    authenticate!
  end

  def authenticate!
    raise AuthenticationError if
        @config['sugarcrm_username'].nil? || @config['sugarcrm_password'].nil?

    @client = Oauth2Client.new CLIENT_ID,
                               CLIENT_SECRET,
                               BASE_API_URI,
                               @config['sugarcrm_url'],
                               @config['sugarcrm_username'],
                               @config['sugarcrm_password']
  end

  def server_mode
    # Augury.test? ? 'Test' : 'Production'
    (ENV['SUGARCRM_ENDPOINT_SERVER_MODE'] || 'Test').capitalize
  end

  def add_update_customer
    customer = Customer.new(@payload['customer'])
    begin
      sugar_contact_id = get_sugar_contact_id(customer)
      customer.sugar_contact_id = sugar_contact_id
      sugar_account_id = get_sugar_account_id(customer)
      "Customer with Hub ID #{customer.spree_id} was added / updated."
    rescue => e
      message = "Unable to add / update customer with Hub ID #{customer.spree_id}: \n" + e.message
      raise SugarcrmAddUpdateObjectError, message, caller
    end
  end
  
  def add_order
    order = Order.new(@payload['order']) 
    customer = Customer.new(@payload['order']) 
    begin
      sugar_contact_id = get_sugar_contact_id(customer)
      customer.sugar_contact_id = sugar_contact_id
      sugar_account_id = get_sugar_account_id(customer)

      ## Create Opportunity in SugarCRM
      oauth_response = @client.post '/Opportunities',
                                    order.sugar_opportunity
      sugar_opp_id = oauth_response['id']
      
      ## Associate with corresponding Sugar Account
      @client.post "/Opportunities/" + sugar_opp_id +
                   "/link/accounts/" + sugar_account_id
      
      ## Create one RevenueLineItem in SugarCRM for each Order line item
      ## and link to corresponding ProductTemplate and Opportunity.
      order.sugar_revenue_line_items.each do |rli|
        oauth_response = @client.post "/Opportunities/" + sugar_opp_id +
                                      "/link/revenuelineitems",
                                      rli

        ## Todo: Create product for each RLI if one does not exist 
      end
  
      "Order with Hub ID #{order.spree_id} was added."
    rescue => e
      message = "Unable to add order #{order.spree_id}: \n" + e.message
      raise SugarcrmAddUpdateObjectError, message, caller
    end
  end
  
  def update_order
    order = Order.new(@payload['order'])
    begin
      @client.put '/Opportunities/' + order.id,
                  order.sugar_opportunity

      ## Todo:
      ## Delete Opportunity's RLIs here and recreate

      "Order #{order.id} was updated."
    rescue => e
      message = "Unable to update order #{order.id}: \n" + e.message
      raise SugarcrmAddUpdateObjectError, message, caller
    end
  end
  
  def add_order_shipment_notes
    @payload['shipments'].each do |shipment_hash|
      shipment = Shipment.new(shipment_hash)
      begin
        @client.post "/Opportunities/" + shipment.order_id +
                      "/link/notes/",
                      shipment.sugar_note

        "Notes for shipment with Hub ID #{shipment.spree_id} were added."
      rescue => e
        message = "Unable to add notes for shipment with Hub ID #{shipment.spree_id}: \n" +
                  e.message
        raise SugarcrmAddUpdateObjectError, message, caller
      end
    end
  end
  
  ## Todo: Instead of setting Sugar's ProductTemplate id to the sku, put the
  ## sku in a field.
  def add_product
    @payload['products'].each do |product_hash|
      product = Product.new(product_hash) 
      begin
        ## Create matching ProductTemplate in SugarCRM
        @client.post '/ProductTemplates',
                     product.sugar_product_template
    
        "Product #{product.id} was added."
      rescue => e
        message = "Unable to add product #{product.id}: \n" + e.message
        raise SugarcrmAddUpdateObjectError, message, caller
      end
    end
  end
  
  def update_product
    product = Product.new(@payload['product'])
    begin
      @client.put '/ProductTemplates/' + product.id,
                  product.sugar_product_template
  
      "Product #{product.id} was updated."
    rescue => e
      message = "Unable to update product #{product.id}: \n" + e.message
      raise SugarcrmAddUpdateObjectError, message, caller
    end
  end
  
  ######################
  
  private
  
  def get_sugar_contact_id(customer)
    oauth_response = @client.get '/Contacts/' +
                                 '?filter[0][email_addresses.email_address_caps]=' +
                                 customer.email.upcase +
                                 '&fields=id'
    begin
      sugar_id = oauth_response['records'][0]['id']
      @client.put "/Contacts/" + sugar_id,
                  customer.sugar_contact
    rescue
      ## If that failed, it means a contact with that email does not exist, and
      ## we will have to create one.
      oauth_response = @client.post '/Contacts', customer.sugar_contact
      sugar_id = oauth_response['id']
    end
    
    sugar_id
  end

  def get_sugar_account_id(customer)
    oauth_response = @client.get '/Accounts/filter' +
                                 '?filter[0][contacts.id]=' +
                                 customer.sugar_contact_id +
                                 '&fields=id'
    begin
      ## Unlike with a contact, do not update parent accounts that already exist.
      sugar_id = oauth_response['records'][0]['id']
    rescue
      ## If that failed, it means no account with a contact with that email exists, and
      ## we need to create one, then link to the contact.
      oauth_response = @client.post '/Accounts', customer.sugar_account
      sugar_id = oauth_response['id']
      @client.post "/Contacts/" + customer.sugar_contact_id +
                   "/link/accounts/" + sugar_id,
                   {}
    end
    
    sugar_id
  end

end

class AuthenticationError < StandardError; end
class SugarcrmAddUpdateObjectError < StandardError; end