class Comparator

  def run(category, product, with_queue)
    #product is after JSON.parse 
    #params is a hash of parameters of the product fetched from a page
    params = get_product_params(product)
    # product_in_db = category.products.find_by(name: params[:name])
    # if product_in_db.nil?
      product_in_db = category.products.create(params)
      # Prices_handler.perform_async(product['html_url'], product_in_db.id) if with_queue && (params[:min_price] != 'N/A')
    # else
    #   check_equality(product_in_db, params)
    # end
  end

  private 
  
  def get_product_params(product)
    small_image_url = product['images']['icon'].nil? ? product['images']['header'] : product['images']['icon']
    large_image_url = product['images']['header'].nil? ? product['images']['icon'] : product['images']['header']
    if product['prices'].nil?
      min_price = max_price = 'N/A'
    else
      min_price = divide(product['prices']['min'])
      max_price = divide(product['prices']['max'])
    end
    {
      name: product['full_name'].strip,
      url: product['html_url'].strip,
      large_image_url: large_image_url.strip,
      small_image_url: small_image_url.strip,
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
