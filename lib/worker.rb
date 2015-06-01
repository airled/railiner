require 'json'
require 'curb'

class Worker

  URL = 'http://catalog.onliner.by'

  def run(url)
    get_category_products(url)
    find_category_db(url)
    compare_web_to_db
  end

  def get_category_products(category_url)
    @hash_of_products_from_web = []
    page_number = 1
    while page_number
      category_url_for_worker = 'https://catalog.api.onliner.by/search/' + category_url.sub(URL,'').delete('/') + "?page=#{page_number}"
      page = JSON.parse(Curl.get(category_url_for_worker).body_str)
      page_number = if page['products'].any?
        page['products'].map do |product|
          url = product['html_url']
          name = product['full_name']
          image_url = product['images']['header']
          @hash_of_products_from_web << {url: url, name: name, image_url: image_url}
          File.open('web.txt','w') { |x| x.puts @hash_of_products_from_web }
        end
        page_number += 1
      end || false
    end
    puts "Elements of category in web: #{@hash_of_products_from_web.size}"
  end

  def find_category_db(category_url)
    category = Category.find_by(url: category_url)
    @hash_of_products_from_db = category.products.map { |product| {url: product.url, name: product.name, image_url: product.image_url} }
    puts "Elements of category in db: #{@hash_of_products_from_db.size}"
    File.open('db.txt','w') { |x| x.puts @hash_of_products_from_db }
  end

  def compare_web_to_db
    new = []
    modified = []
    @hash_of_products_from_web.each do |hash_web_product|
      mismatch_count = 0;
      @hash_of_products_from_db.each do |hash_db_product|
        if hash_web_product[:url] == hash_db_product[:url] && (hash_web_product[:name] != hash_db_product[:name] || hash_web_product[:image_url] != hash_db_product[:image_url])
          modified << hash_web_product
        end
        if hash_web_product[:url] != hash_db_product[:url]
          mismatch_count += 1 
        end
      end
      if mismatch_count == @hash_of_products_from_db.size
        new << hash_web_product
      end
    end
    puts "Existing records to modify: #{modified.size}"
    puts "New records to add: #{new.size}"
  end

  def compare_db_to_web
  end

  def create_product
  end

  def update
  end

  def destroy
  end
  
end

# url = 'http://catalog.onliner.by/mobile/'
# Worker.new.find_from_db(url)

# Worker.new.get_category_products('http://catalog.onliner.by/mobile/');
# A="https://catalog.api.onliner.by/search/mobile?birthday[from]=2015&mp_ruggedcase=false&is_actual=1"

# select count(*) from categories_products join categories on categories.id=categories_products.category_id join products on products.id=categories_products.product_id where categories.name='mobile';