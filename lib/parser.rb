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
          products_request_url = 'https://catalog.api.onliner.by/search/' + category['url'].sub('http://catalog.onliner.by/','').split('/').first.split('?').first
          pages_quantity = JSON.parse(request(products_request_url))['page']['last'].to_i
          puts "Current category: #{category['title']}/#{pages_quantity} pages"
          1.upto(pages_quantity) do |page_number|
            get_products_from_page(products_request_url + '?page=' + page_number.to_s, db_category)
          end
          sleep(5)
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
    # Curl.get(url).body_str
    user_agents = ['Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:39.0) Gecko/20100101 Firefox/39.0', 'Mozilla/5.0 (Windows NT 6.1; rv:35.0) Gecko/20100101 Firefox/35.0', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.155 Safari/537.36']
    data = Curl::Easy.new(url) do |http| 
      http.headers["User-Agent"] = user_agents[rand(user_agents.size)]
    end
    data.perform
    data.body_str
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



