require 'oauth2'

class Sugarcrm
  @client_id = "sugar"
  @client_secret = ""
  @client_url = 'https://nssegc3123.trial.sugarcrm.com'
  @base_api_uri = '/rest/v10'

  attr_accessor :order, :config, :payload, :request

  def initialize(payload, config={})
    @payload = payload
    @config = config

    authenticate!
  end

  def authenticate!
    raise AuthenticationError if
        @config['sugarcrm_username'].nil? || @config['sugarcrm_password'].nil?
    client = OAuth2::Client.new @client_id, @client_secret,
                                :token_url => @base_api_uri + '/oauth2/token',
                                :site => @client_url
    token_request = client.password.get_token(username, password)
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
    ## Check if account exists in sugar first
    @request.post @base_api_uri + 'Accounts', @payload['account']

    ## Check if contact exists in sugar first
    @request.post @base_api_uri + 'Contacts', @payload['contact']

    ## Associate customer w account
    link_hash = JSON.parse('{ "link_name": "contacts", "ids": ["demo_bob_burger"] }')
    @request.post @base_api_uri + 'Accounts/#{id}/link', link_hash
  end

end

class AuthenticationError < StandardError; end
class SugarcrmSubmitOrderError < StandardError; end
class SendError < StandardError; end