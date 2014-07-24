require 'date'

class Order

  def initialize(spree_order = {})
    @spree_order = spree_order
  end

  def wombat_id
    @spree_order['id']
  end

  def description
    @spree_order.to_s
    desc = "Number: #{wombat_id}\n"
    desc += "Status: #{@spree_order['status']}\n"
    desc += "Items: \n"
    @spree_order['line_items'].each do |item|
      desc += "- #{item['product_id']}, #{item['name']}, #{item['quantity']} unit(s)\n"
    end
    ['item', 'adjustment', 'tax', 'shipping', 'payment', 'order'].each do |adjustment|
      desc += "#{adjustment.capitalize} Total: #{@spree_order['totals'][adjustment]}\n"
    end

    desc
  end

  def email
    @spree_order['email']
  end

  def sugar_opportunity
    opportunity = Hash.new
    opportunity['id'] = wombat_id
    opportunity['sales_stage'] = 'Closed Won'
    opportunity['name'] = "Wombat ID #{@spree_order['id']}"
    opportunity['description'] = description
    opportunity['lead_source'] = 'Web Site'
    opportunity['date_closed'] = DateTime.parse(@spree_order['placed_on']).to_date.to_s
    opportunity['amount'] = @spree_order['totals']['order']
    return opportunity
  end

  def sugar_revenue_line_items
    rlis = Array.new

    ## Add one RLI for each line item
    @spree_order['line_items'].each do |line_item|
      rli = Hash.new
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

    ## And one RLI for each adjustment, tax, shipping
    ['adjustment', 'tax', 'shipping'].each do |adjustment|
      rli = Hash.new
      rli['name'] = adjustment
      rli['quantity'] = 1
      rli['cost_price'] = @spree_order['totals'][adjustment]
      rli['list_price'] = @spree_order['totals'][adjustment]
      rli['likely_case'] = @spree_order['totals'][adjustment]
      rli['sales_stage'] = 'Closed Won'
      rli['probability'] = 100
      rli['date_closed'] = DateTime.parse(@spree_order['placed_on']).to_date.to_s
      rlis.append(rli)
    end

    return rlis
  end

end
