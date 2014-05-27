class Product

  def initialize(spree_product = {})
    @spree_product = spree_product
  end
  
  def id
    @spree_product['sku']
  end
  
  def sugar_product_template
    product = Hash.new
    product['id'] = @spree_product['sku']
    product['name'] = @spree_product['name']
    product['description'] = @spree_product['description']
    product['cost_price'] = @spree_product['cost_price']
    product['list_price'] = @spree_product['price']
    return product
  end

end