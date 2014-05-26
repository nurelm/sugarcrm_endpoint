require 'oauth2'

class Sugarcrm
  CLIENT_ID = "sugar"
  CLIENT_SECRET = ""
  CLIENT_URL = "https://wycpng2607.trial.sugarcrm.com"
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
    client = OAuth2::Client.new CLIENT_ID, CLIENT_SECRET,
                                :token_url => BASE_API_URI + '/oauth2/token',
                                :site => CLIENT_URL
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
    (ENV['SUGARCRM_ENDPOINT_SERVER_MODE'] || 'Test').capitalize
  end

  def add_customer
    customer = Customer.new(@payload['customer'])
    response = ""
    begin
      ## Create identical Account and Contact in Sugar
      response = @request.post BASE_API_URI + '/Accounts',
                               params: customer.sugar_account
      response = @request.post BASE_API_URI + '/Contacts',
                               params: customer.sugar_contact
  
      ## Associate Sugar Account and Contact
      response = @request.post BASE_API_URI +
                               "/Contacts/" + customer.id + "/link/accounts/" + customer.id

      "Successfully sent customer to SugarCRM"
    rescue => e
      raise SugarcrmAddCustomerError, response + "\n" + e.message, caller
    end
  end
  
  def update_customer
    customer = Customer.new(@payload['customer'])
    response = ""
    begin
      ## Update Account
      response = @request.put BASE_API_URI + "/Accounts/" + customer.id,
                              params: customer.sugar_account
      ## Update Contact
      response = @request.put BASE_API_URI + "/Contacts/" + customer.id,
                              params: customer.sugar_contact

      "Successfully updated customer"
    rescue => e
      raise SugarcrmUpdateCustomerError, response + "\n" + e.message, caller
    end
  end

end

class AuthenticationError < StandardError; end
class SugarcrmAddCustomerError < StandardError; end
class SugarcrmUpdateCustomerError < StandardError; end