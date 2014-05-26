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
    opportunity['sales_status'] = 'Closed Won'
    opportunity['name'] = "Spree Hub ID #{@spree_order['id']}"
    opportunity['description'] = @spree_order.to_s
    opportunity['lead_source'] = 'ecomm'
    opportunity['date_closed'] = @spree_order['placed_on']
    opportunity['amount'] = @spree_order['totals']['order']
    if @spree_order['currency'] == 'USD'
      opportunity['amount_usdollar'] = @spree_order['totals']['order']
    end
    return opportunity
  end

end