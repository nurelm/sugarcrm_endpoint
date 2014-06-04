class Customer
  
  attr_accessor :sugar_contact_id

  def initialize(spree_customer = {})
    @spree_customer = spree_customer
    
    if @spree_customer['first_name'].nil? || @spree_customer['first_name'].empty?
      @spree_customer['first_name'] = @spree_customer['billing_address']['firstname']
    end
    if @spree_customer['last_name'].nil? || @spree_customer['last_name'].empty?
      @spree_customer['last_name'] = @spree_customer['billing_address']['lastname']
    end
  end
  
  def spree_id
    @spree_customer['id']
  end

  def email
    @spree_customer['email']
  end
  
  def sugar_account
    account = Hash.new
    account['name'] = "#{@spree_customer['firstname']} #{@spree_customer['lastname']}"
    account['description'] = "#{@spree_customer['firstname']} #{@spree_customer['lastname']}"
    account['email1'] = @spree_customer['email']
    account['shipping_address_street'] = @spree_customer['shipping_address']['address1']
    account['shipping_address_street_2'] = @spree_customer['shipping_address']['address2']
    account['shipping_address_city'] = @spree_customer['shipping_address']['city']
    account['shipping_address_state'] = @spree_customer['shipping_address']['state']
    account['shipping_address_postalcode'] = @spree_customer['shipping_address']['zipcode']
    account['shipping_address_country'] = @spree_customer['shipping_address']['country']
    account['billing_address_street'] = @spree_customer['billing_address']['address1']
    account['billing_address_street_2'] = @spree_customer['billing_address']['address2']
    account['billing_address_city'] = @spree_customer['billing_address']['city']
    account['billing_address_state'] = @spree_customer['billing_address']['state']
    account['billing_address_postalcode'] = @spree_customer['billing_address']['zipcode']
    account['billing_address_country'] = @spree_customer['billing_address']['country']
    account['phone_office'] = @spree_customer['billing_address']['phone']
    account['phone_alternate'] = @spree_customer['shipping_address']['phone']
    account['lead_source'] = 'ecomm'
    return account
  end
  
  def sugar_contact
    contact = Hash.new
    contact['first_name'] = @spree_customer['firstname']
    contact['last_name'] = @spree_customer['lastname']
    contact['description'] = "#{@spree_customer['firstname']} #{@spree_customer['lastname']}"
    contact['email1'] = @spree_customer['email']
    contact['primary_address_street'] = @spree_customer['shipping_address']['address1']
    contact['primary_address_street_2'] = @spree_customer['shipping_address']['address2']
    contact['primary_address_city'] = @spree_customer['shipping_address']['city']
    contact['primary_address_state'] = @spree_customer['shipping_address']['state']
    contact['primary_address_postalcode'] = @spree_customer['shipping_address']['zipcode']
    contact['primary_address_country'] = @spree_customer['shipping_address']['country']
    contact['alt_address_street'] = @spree_customer['billing_address']['address1']
    contact['alt_address_street_2'] = @spree_customer['billing_address']['address2']
    contact['alt_address_city'] = @spree_customer['billing_address']['city']
    contact['alt_address_state'] = @spree_customer['billing_address']['state']
    contact['alt_address_postalcode'] = @spree_customer['billing_address']['zipcode']
    contact['alt_address_country'] = @spree_customer['billing_address']['country']
    contact['phone_home'] = @spree_customer['billing_address']['phone']
    contact['phone_work'] = @spree_customer['billing_address']['phone']
    contact['phone_other'] = @spree_customer['shipping_address']['phone']
    contact['lead_source'] = 'ecomm'
    return contact
  end

end