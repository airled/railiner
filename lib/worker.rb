require 'json'
require 'curb'

class Worker

  URL = 'http://catalog.onliner.by'

  def run(category_url)
    get_web_category_products(category_url)
    find_category_products_in_db(category_url)
    compare_web_to_db
    if @modified.size != 0
      puts "Do you like to update your records? Y/n"
      answer = STDIN.gets.chomp
      case answer
      when 'Y','y' 
        update_products_in_db
      when 'N','n'
        puts "Records have not been updated"
      else puts 'Error. No such option'
      end
    end
    if @new.size != 0
      puts "Do you like to add new records? Y/n"
      answer = STDIN.gets.chomp
      case answer
      when 'Y','y' 
        create_new_products_in_db(category_url)
      when 'N','n'
        puts "New records have not been added"
      else puts 'Error. No such option'
      end
  end

  private

  def get_web_category_products(category_url)
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

  def find_category_products_in_db(category_url)
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
    puts "Existing records to update: #{@modified.size}"
    puts "New records to add: #{@new.size}"
  end

  def create_new_products_in_db(category_url)
    puts 'Adding new records...'
    category = Category.find_by(url: category_url)
    @new.map do { |new_product_hash| Category.products.create(new_product_hash)}
    puts 'Added'
  end

  def update_products_in_db
    puts 'Updating database records...'
    @modified.map do |updated_product_hash|
      product = Product.find_by(url: updated_product_hash[:url])
      product.update(updated_product_hash)
    end
    puts 'Updated'
  end
  
end

# A="https://catalog.api.onliner.by/search/mobile?birthday[from]=2015&mp_ruggedcase=false&is_actual=1"

# select count(*) from categories_products join categories on categories.id=categories_products.category_id join products on products.id=categories_products.product_id where categories.name='mobile';
