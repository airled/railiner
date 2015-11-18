class Comparator

  def run(category, product)
    #product is after JSON.parse 
    #params is a hash of parameters of the product fetched from a page
    params = get_product_params(product)
    product_in_db = Product.find_by(name: params[:name])
    if product_in_db.nil?
      category.products.create(params)
    else
      check_equality(product_in_db, params)
    end

  end

  private 
  
  def get_product_params(product)
    image_url = (product['images']['icon'].nil?) ? product['images']['header'].strip : product['images']['icon'].strip
    if product['prices'].nil?
      min_price = max_price = 'N/A'
    else
      min_price = divide(product['prices']['min'])
      max_price = divide(product['prices']['max'])
    end

    {
      name: product['full_name'].strip,
      url: product['html_url'].strip,
      image_url: image_url,
      max_price: max_price,
      min_price: min_price,
      description: Nokogiri::HTML.parse(product['description']).text.strip
    }
  end

  #make price look more readable (1 000 instead of 1000)
  def divide(price)
    price.to_s.reverse.scan(/\d{1,3}/).join(' ').reverse.strip
  end

  def check_equality(product_in_db, params)
    changes = {}
    [:url, :image_url, :max_price, :min_price, :description].map do |attrib|
      changes.merge!(attrib => params[attrib]) if product_in_db[attrib] != params[attrib]
    end
    product_in_db.update(changes)
  end

end
