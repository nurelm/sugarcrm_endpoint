require 'date'

class Order

  def initialize(spree_order = {})
    @spree_order = spree_order
  end
  
  def id
    @spree_order['id']
  end
  
  def sugar_opportunity
    opportunity = Hash.new
    opportunity['id'] = @spree_order['id']
    opportunity['sales_status_dom'] = 'Closed Won'
    opportunity['name'] = "Spree Hub ID #{@spree_order['id']}"
    opportunity['description'] = @spree_order.to_s
    opportunity['lead_source'] = 'ecomm'
    opportunity['date_closed'] = DateTime.parse(@spree_order['placed_on']).to_date.to_s
    opportunity['amount'] = @spree_order['totals']['order']
    return opportunity
  end
  
  def sugar_revenue_line_item
    rli = Hash.new
    rli['id'] = @spree_order['id']
    rli['sales_status'] = 'Closed Won'
    rli['name'] = "Spree Hub ID #{@spree_order['id']}"
    rli['description'] = @spree_order.to_s
    rli['lead_source'] = 'ecomm'
    rli['date_closed'] = DateTime.parse(@spree_order['placed_on']).to_date.to_s
    rli['amount'] = @spree_order['totals']['order']
    return rli
  end

end