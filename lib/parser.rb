require 'nokogiri'
require 'open-uri'
require 'json'
require 'curb'

class Parser

  URL = 'http://catalog.onliner.by'

  def run
    start_time = Time.new
    html = get_html(URL)
    script_tag = html.xpath('//div[@class="g-middle"]/div[@class="g-middle-i"]/script[1]').text.strip
    hash = get_hash(script_tag)
    puts 'Adding database records...'
    hash.map do |large_group|
      large_group[1]['groups'].map do |group|
        db_group = create_group(group['title'])
        group['links'].map do |category|
          db_category = create_group_category(db_group, category['url'], category['title'])

          products_request_url = 'https://catalog.api.onliner.by/search/' + category['url'].split('/').last
          pages_quantity = JSON.parse(request(products_request_url))['page']['last'].to_i
          
          1.upto(pages_quantity) do |page_number|
            get_products_from_page(products_request_url + '?page=' + page_number.to_s, db_category)
            
            # c = Curl::Easy.new("http://www.google.co.uk") do |curl| 
            #   curl.headers["User-Agent"] = "myapp-0.0"
            #   curl.verbose = true
            # end
            # c.perform


          end

        end
      end
    end
    stop_time = Time.new
    results(stop_time, start_time)
  end

  private

  def get_html(source)
    puts 'Getting HTML...'
    Nokogiri::HTML(open(source))
  end

  def request(url)
    Curl.get(url).body_str
  end

  def get_hash(text)
    puts "Parsing script's JSON..."
    JSON.parse(text.sub('window.categories = ', '').chop)
  end

  def get_products_from_page(url, category)
    json = request(url)
    JSON.parse(json)['products'].map do |product|
      name = product['full_name']
      category.products.create(name: name)
    end
  end

  def create_group(name_ru)
    Group.create(name_ru: name_ru)
  end

  def create_group_category(group, url, name_ru)
    group.categories.create(url: url, name_ru: name_ru)
  end

#calculating parsing time and amount of fetched objects
  def results(stop, start)
    secs_total = (stop - start).to_i
    hours = secs_total / 3600
    mins = (secs_total - hours * 3600) / 60
    secs = secs_total - hours * 3600 - mins * 60
    puts "Done in #{hours}:#{mins}:#{secs}"
    puts "Got: #{Group.count} groups, #{Category.count} categories, #{Product.count} products"
  end

end

Parser.new.run
