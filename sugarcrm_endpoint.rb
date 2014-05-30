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

  post '/get_customer' do
    "Coming soon ..."
  end

  post '/add_order' do
    sugar_action('add_order')
  end

  post '/update_order' do
    sugar_action('update_order')
  end

  get '/get_orders' do
    "Coming soon ..."
  end

  post '/add_product' do
    sugar_action('add_product')
  end

  post '/update_product' do
    sugar_action('update_product')
  end

  get '/get_product' do
    "Coming soon ..."
  end

  post '/add_shipment' do
    sugar_action('add_order_shipment_notes')
  end

  post '/update_shipment' do
    sugar_action('add_order_shipment_notes')
  end

  get '/get_shipment' do
    "Coming soon ..."
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