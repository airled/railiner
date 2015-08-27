require 'nokogiri'
require 'open-uri'
require 'json'
require 'curb'

class Parser

  URL = 'http://catalog.onliner.by/'

  def run
    html = get_html(URL) 
    group_nodes = []
    categories_nodes = []
    html.xpath('//h2[@class="catalog-navigation-list__group-title"]').map { |group_node| group_nodes << group_node }
    html.xpath('//ul[@class="catalog-navigation-list__links"]').map { |categories_node| categories_nodes << categories_node }
    group_nodes.zip(categories_nodes).map do |group_node, categories_node|
      db_group = create_group(group_node.text)
      categories_node.xpath('./li/span[@class="catalog-navigation-list__link-inner"]').map do |node|
        create_group_category(db_group, node)
      end
    end
  end

  def get_html(source)
    puts 'Getting HTML...'
    Nokogiri::HTML(open(source))
  end

   def create_group(name_ru)
    Group.create(name_ru: name_ru)
  end

  def create_group_category(group, node)
    url = node.xpath('./a/@href').text
    name_ru = node.xpath('./a/@title').text
    name = node.xpath('./a/@href').text.sub(URL,'').split('?').first
    group.categories.create(url: url, name_ru: name_ru, name: name)
  end

end

Parser.new.run
