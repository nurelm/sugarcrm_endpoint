require 'oauth2'
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
    raise AuthenticationError if @config['sugarcrm_username'].nil? || @config['sugarcrm_password'].nil?

    client = OAuth2::Client.new CLIENT_ID, CLIENT_SECRET,
                                :token_url => BASE_API_URI + '/oauth2/token',
                                :site => @config['sugarcrm_url'],
                                :connection_opts => {
                                  :request => {
                                    :params_encoder => Faraday::FlatParamsEncoder
                                  }
                                }
    token_request = client.password.get_token(
      @config['sugarcrm_username'], @config['sugarcrm_password'])
    token_string = token_request.token
    @request = OAuth2::AccessToken.new client,
                                       token_string,
                                       :header_format => "%s",
                                       :header_auth_field => "OAuth-Token"
  end

  def server_mode
    # Augury.test? ? 'Test' : 'Production'
    (ENV['SUGARCRM_INTEGRATION_SERVER_MODE'] || 'Test').capitalize
  end

  def add_update_customer
    customer = Customer.new(@payload['customer'])
    begin
      email_address_id = get_sugar_email_id(customer)
      sugar_contact_id = get_sugar_contact_id(customer, email_address_id)
      customer.sugar_contact_id = sugar_contact_id
      sugar_account_id = get_sugar_account_id(customer, email_address_id)
      "Customer with Wombat ID #{customer.spree_id} was added / updated."
    rescue => e
      message = "Unable to add / update customer with Wombat ID #{customer.spree_id}: \n" + e.message
      raise SugarcrmAddUpdateObjectError, message, caller
    end
  end

  def add_order
    order = Order.new(@payload['order'])
    customer = Customer.new(@payload['order'])
    begin
      email_address_id = get_sugar_email_id(customer)
      sugar_contact_id = get_sugar_contact_id(customer, email_address_id)
      customer.sugar_contact_id = sugar_contact_id
      sugar_account_id = get_sugar_account_id(customer, email_address_id)

      ## Create Opportunity in SugarCRM
      oauth_response = @request.post BASE_API_URI + '/Opportunities',
                                     params: order.sugar_opportunity
      sugar_opp_id = JSON.parse(oauth_response.response.body)['id']

      ## Associate with corresponding Sugar Account
      @request.post BASE_API_URI +
                    "/Opportunities/" + sugar_opp_id +
                    "/link/accounts/" + sugar_account_id

      ## Create one RevenueLineItem in SugarCRM for each Order line item
      ## and link to corresponding ProductTemplate and Opportunity.
      order.sugar_revenue_line_items.each do |rli|
        oauth_response = @request.post BASE_API_URI +
                                       "/Opportunities/" + sugar_opp_id +
                                       "/link/revenuelineitems",
                                       params: rli

        ## Todo: Create product for each RLI if one does not exist
      end

      "Order with Wombat ID #{order.spree_id} was added."
    rescue => e
      message = "Unable to add order #{order.spree_id}: \n" + e.message
      raise SugarcrmAddUpdateObjectError, message, caller
    end
  end

  def update_order
    order = Order.new(@payload['order'])
    begin
      @request.put BASE_API_URI + '/Opportunities/' + order.id,
                   params: order.sugar_opportunity

      ## Todo:
      ## Delete Opportunity's RLIs here and recreate

      "Order #{order.id} was updated."
    rescue => e
      message = "Unable to update order #{order.id}: \n" + e.message
      raise SugarcrmAddUpdateObjectError, message, caller
    end
  end

  def add_order_shipment_notes
    if @payload['shipment'].present?
      @payload['shipments'] = [@payload['shipment']]
    end
    @payload['shipments'].each do |shipment_hash|
      shipment = Shipment.new(shipment_hash)
      begin
        @request.post BASE_API_URI +
                      "/Opportunities/" + shipment.order_id +
                      "/link/notes/",
                      params: shipment.sugar_note

        "Notes for shipment with Wombat ID #{shipment.spree_id} were added."
      rescue => e
        message = "Unable to add notes for shipment with Wombat ID #{shipment.spree_id}: \n" +
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
        @request.post BASE_API_URI + '/ProductTemplates',
                      params: product.sugar_product_template

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
      @request.put BASE_API_URI + '/ProductTemplates/' + product.id,
                   params: product.sugar_product_template

      "Product #{product.id} was updated."
    rescue => e
      message = "Unable to update product #{product.id}: \n" + e.message
      raise SugarcrmAddUpdateObjectError, message, caller
    end
  end

  ######################

  private

  def get_sugar_account_id(customer, email_address_id = nil)
    oauth_response = @request.get BASE_API_URI + '/Accounts/filter' +
                                                 '?filter[0][contacts.id]=' +
                                                 customer.sugar_contact_id +
                                                 '&fields=id'
    begin
      ## Unlike with a contact, do not update parent accounts that already exist.
      sugar_id = JSON.parse(oauth_response.response.body)['records'][0]['id']
    rescue
      ## If that failed, it means no account with a contact with that email exists, and
      ## we need to create one, then link to the contact.
      oauth_response = @request.post BASE_API_URI + '/Accounts', params: customer.sugar_account
      puts "get_sugar_account_id: #{JSON.parse(oauth_response.response.body).inspect}"
      sugar_id = JSON.parse(oauth_response.response.body)['id']

      # Link the EmailAddress.
      @request.post BASE_API_URI +
                    "/Accounts/" + sugar_id +
                    "/link/email_addresses/" + email_address_id

      # Link the Contact
      @request.post BASE_API_URI +
                    "/Contacts/" + customer.sugar_contact_id +
                    "/link/accounts/" + sugar_id
    end

    sugar_id
  end

  def get_sugar_contact_id(customer, email_address_id = nil)
    oauth_response = @request.get BASE_API_URI + '/Contacts/filter' +
                                                 '?filter[0][email_addresses.email_address_caps]=' +
                                                 customer.email.upcase +
                                                 '&fields=id,email'

    begin
      customer.sugar_contact_id = JSON.parse(oauth_response.response.body)['records'][0]['id']
      oauth_response = @request.put BASE_API_URI + "/Contacts/" + customer.sugar_contact_id,
                   params: customer.sugar_contact
    rescue
      ## If that failed, it means a contact with that email does not exist, and
      ## we will have to create one.
      oauth_response = @request.post BASE_API_URI + '/Contacts', params: customer.sugar_contact
      customer.sugar_contact_id = JSON.parse(oauth_response.response.body)['id']

      # Link the Email address.
      @request.post BASE_API_URI +
                    "/Contacts/" + customer.sugar_contact_id +
                    "/link/email_addresses/" + email_address_id
    end

    customer.sugar_contact_id
  end

  def get_sugar_email_id(customer)
    oauth_response = @request.get BASE_API_URI + '/EmailAddresses/filter' +
                                                 '?filter[0][email_address_caps]=' +
                                                 customer.email.upcase +
                                                 '&fields=id,email_address,email_address_caps'

    puts "get_sugar_email_id get: #{JSON.parse(oauth_response.response.body).inspect}"
    customer.sugar_email_id = JSON.parse(oauth_response.response.body)['id']

    if customer.sugar_email_id.blank?
      oauth_response = @request.post BASE_API_URI + '/EmailAddresses', params: customer.email_address
      customer.sugar_email_id = JSON.parse(oauth_response.response.body)['id']
    end

    customer.sugar_email_id
  end

end

class AuthenticationError < StandardError; end
class SugarcrmAddUpdateObjectError < StandardError; end
