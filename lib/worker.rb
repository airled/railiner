require 'json'
require 'curb'

class Worker

  URL = 'http://catalog.onliner.by'

  def get_category_products(category_url)
    @hash_of_products_from_web = []
    page_number = 1
    while page_number
      category_url_for_worker = 'https://catalog.api.onliner.by/search/' + category_url.sub(URL,'').delete('/') + "?page=#{page_number}"
      page = JSON.parse(Curl.get(category_url_for_worker).body_str)
      page_number = if page['products'].any?
        page['products'].map do |x|
          url = x['html_url']
          name = x['full_name']
          image_url = x['images']['header']
          @hash_of_products_from_web << {url: url, name: name, image_url: image_url}
        end
        page_number +=1
      end || false
    end
  end

  def find_category_db(category_url)
    category = Category.find_by(url: category_url)
    @hash_of_products_from_db = category.products.map { |product| {url: product.url, name: product.name, image_url: product.image_url} }
    p @hash_of_products_from_db
  end

  def compare
    # @hash_of_products_from_web.map do |product_hash|

    # end
  end

  def create_product
  end

  def update
  end
  
end

# url = 'http://catalog.onliner.by/mobile/'
# Worker.new.find_from_db(url)

# Worker.new.get_category_products('http://catalog.onliner.by/mobile/');
# A="https://catalog.api.onliner.by/search/mobile?birthday[from]=2015&mp_ruggedcase=false&is_actual=1"