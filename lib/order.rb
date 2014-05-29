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
    opportunity['sales_stage'] = 'Closed Won'
    opportunity['name'] = "Spree Hub ID #{@spree_order['id']}"
    opportunity['description'] = @spree_order.to_s
    opportunity['lead_source'] = 'ecomm'
    opportunity['date_closed'] = DateTime.parse(@spree_order['placed_on']).to_date.to_s
    opportunity['amount'] = @spree_order['totals']['order']
    return opportunity
  end
  
  def sugar_revenue_line_items
    rlis = Array.new
    @spree_order['line_items'].each do |line_item|
      rli = Hash.new
      rli['id'] = @spree_order['id'] + "-" + line_item['product_id']
      rli['sku'] = line_item['product_id']
      rli['product_template_id'] = line_item['product_id']
      rli['name'] = line_item['name']
      rli['quantity'] = line_item['quantity']
      rli['cost_price'] = line_item['price']
      rli['list_price'] = line_item['price']
      rli['likely_case'] = line_item['quantity'] * line_item['price']
      rli['sales_stage'] = 'Closed Won'
      rli['probability'] = 100
      rli['date_closed'] = DateTime.parse(@spree_order['placed_on']).to_date.to_s
      rlis.append(rli)
    end
    return rlis
  end

end