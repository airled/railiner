require 'json'
require 'curb'

class Worker

  URL = 'http://catalog.onliner.by'
  url = 'http://catalog.onliner.by/mobile/'

  def run(url)
    get_category_products(url)
    find_category_db(url)
    compare_web_to_db
    if @modified.size != 0
      puts "Do you like to modify your records? Y/n"
      answer = STDIN.gets.chomp
      update if answer == ('Y' || 'y')
    end
  end

  def get_category_products(category_url)
    @products_from_web = []
    page_number = 1
    while page_number
      category_url_for_worker = 'https://catalog.api.onliner.by/search/' + category_url.sub(URL,'').delete('/') + "?page=#{page_number}"
      page = JSON.parse(Curl.get(category_url_for_worker).body_str)
      page_number = if page['products'].any?
        page['products'].map do |product|
          url = product['html_url']
          name = product['full_name']
          image_url = product['images']['header']
          @products_from_web << {url: url, name: name, image_url: image_url}
        end
        page_number += 1
      end || false
    end
    puts "Products of category in web: #{@products_from_web.size}"
  end

  def find_category_db(category_url)
    category = Category.find_by(url: category_url)
    @products_from_db = category.products.map { |product| {url: product.url, name: product.name, image_url: product.image_url} }
    puts "Products of category in db: #{@products_from_db.size}"
  end

  def compare_web_to_db
    @new = []
    @modified = []
    @products_from_web.each do |web_product|
      mismatch_count = 0;
      @products_from_db.each do |db_product|
        if web_product[:url] == db_product[:url] && (web_product[:name] != db_product[:name] || web_product[:image_url] != db_product[:image_url])
          @modified << web_product
        end
        if web_product[:url] != db_product[:url]
          mismatch_count += 1 
        end
      end
      if mismatch_count == @products_from_db.size
        @new << web_product
      end
    end
    puts "Existing records to modify: #{@modified.size}"
    puts "New records to add: #{@new.size}"
  end

  def compare_db_to_web
  end

  def create
  end

  def update
    puts 'Modifying database records...'
    @modified.map do |web_hash|
      product = Product.find_by(url: web_hash[:url])
      product.update(web_hash)
    end
    puts 'Modified'
  end

  def destroy
  end
  
end

# Worker.new.find_from_db(url)

# Worker.new.get_category_products('http://catalog.onliner.by/mobile/');
# A="https://catalog.api.onliner.by/search/mobile?birthday[from]=2015&mp_ruggedcase=false&is_actual=1"

# select count(*) from categories_products join categories on categories.id=categories_products.category_id join products on products.id=categories_products.product_id where categories.name='mobile';