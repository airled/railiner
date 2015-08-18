require 'nokogiri'
require 'open-uri'
require 'json'

class Parser

  URL = 'http://catalog.onliner.by'

  def run
    html = get_html(URL)
    script_tag = html.xpath('//div[@class="g-middle"]/div[@class="g-middle-i"]/script[1]').text.strip
    hash = get_hash(script_tag)
    file = File.open('1.txt','w')

    hash.map do |large_category|
      large_category[1]['groups'].map do |group|
        group['links'].map do |link|
          file << group['title'] + '|||' + link['title'] << "\n"
        end
      end
    end

    file.close

  end

  def get_html(source)
    Nokogiri::HTML(open(source))
  end

  def get_hash(text)
    JSON.parse(text.sub('window.categories = ','').chop)
  end

end

Parser.new.run