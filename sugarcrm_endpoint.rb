require "sinatra"
require "endpoint_base"

require File.expand_path(File.dirname(__FILE__) + '/lib/sugarcrm.rb')
Dir['./lib/**/*.rb'].each { |f| require f }

class SugarcrmEndpoint < EndpointBase::Sinatra::Base
  set :logging, true
  
  post '/add_customer' do
    sugar_action('add_customer')
  end

  post '/update_customer' do
    sugar_action('update_customer')
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
  
  def sugar_action(action)
    begin
      sugarcrm = Sugarcrm.new(@payload, @config)
      response  = sugarcrm.send(action)
      result 200, response
    rescue => e
      print e.cause
      print e.backtrace.join("\n")
      result 500, e.message
    end
  end

end