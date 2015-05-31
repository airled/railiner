require 'json'
require 'curb'
#require 'mysql2'

class Worker

  URL = 'http://catalog.onliner.by'

  def get_category_products(category_page_url)

  end

  def find_category_db
  end

  def compare

  end

  def update

  end
end

# Worker.new.get_category_products('http://catalog.onliner.by/mobile/');
# A="https://catalog.api.onliner.by/search/mobile?birthday[from]=2015&mp_ruggedcase=false&is_actual=1"


# p JSON.parse(Curl.get("https://catalog.api.onliner.by/search/mobile?page=1").body_str)['products'][1]['images']['header']
page_number = 1
while page_number
  page = JSON.parse(Curl.get("https://catalog.api.onliner.by/search/mobile?page=#{page_number}").body_str)
  page_number = if page['products'].any?
    page['products'].map do |x|
      url = x['html_url']
      name = x['full_name']
      image_url = x['images']['header']
    end
    page_number +=1
  end || false
end

