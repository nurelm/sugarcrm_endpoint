require "sinatra"
require "endpoint_base"

require File.expand_path(File.dirname(__FILE__) + '/lib/sugarcrm.rb')
Dir['./lib/**/*.rb'].each { |f| require f }

class SugarcrmEndpoint < EndpointBase::Sinatra::Base
  set :logging, true

  post '/add_customer' do
    begin
  	  sugarcrm = Sugarcrm.new(@payload, @config)
  	  response  = sugarcrm.add_customer

      result 200, 'Successfully sent customer to SugarCRM'
    rescue => e
      result 500, e.message
    end
  end

  put '/update_customer' do

  end

  get '/get_customer' do

  end

  post '/add_order' do

  end

  put '/update_order' do

  end

  get '/get_orders' do

  end

  post '/add_product' do

  end

  put '/update_product' do

  end

  get '/get_product' do

  end

  post '/add_shipment' do

  end

  put '/update_shipment' do

  end

  get '/get_shipment' do

  end

end