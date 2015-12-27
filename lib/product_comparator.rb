require_relative './slack_message'

class Comparator

  def run(category, product, with_queue, page_url)
    begin
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
    rescue => exception
      message = "Exception: #{exception.message} | Failed product: #{product['full_name']} | Page url: #{page_url}"
      puts message
      Slack_message.new.send("#{Time.now} : #{message}", 'danger')
      raise "Comparator error. Failed to handle the product data."
    end
  end

  private 
  
  def get_product_params(product)
    small_image_url = product['images']['icon'].nil? ? product['images']['header'] : product['images']['icon']
    large_image_url = product['images']['header'].nil? ? product['images']['icon'] : product['images']['header']
    if product['prices'].nil?
      min_price = max_price = nil
    else
      min_price = product['prices']['min'].to_i
      max_price = product['prices']['max'].to_i
    end
    {
      name: Nokogiri::HTML.parse(product['full_name']).text.strip,
      url_name: product['html_url'].split('/').last.strip,
      url: product['html_url'].strip,
      large_image_url: large_image_url,
      small_image_url: small_image_url,
      max_price: max_price,
      min_price: min_price,
      description: Nokogiri::HTML.parse(product['description']).text.strip
    }
  end

  #makes the price look more readable (1 000 instead of 1000)
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
