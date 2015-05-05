#Onliner's catalog parser. Fetches groups of categories, categories
#and products of each category and inserts them all into the 
#appropriate MySQL table.
require 'nokogiri'
require 'open-uri'
require 'ruby-progressbar'
require 'singleton'

class Parser

  include Singleton

  #Onliner's catalog URL
  URL = 'http://catalog.onliner.by'

  #parser's work script
  def run
    start_time = Time.new
    #fetching HTML code
    puts 'Fetching start page HTML...'
    html = Nokogiri::HTML(open(URL))
    puts 'Fetched.'
    #fetching groups and categories root nodes
    groups = html.xpath("//h1[@class='cm__h1']")
    categories_blocks = html.xpath("//ul[@class='b-catalogitems']")
    categories_amount = categories_blocks.xpath("./li/div[@class='i']").size
    puts 'Parsing...'
    progress_parameters = {:title => ">Categories", :starting_at => 0, :total => categories_amount}
    categories_bar = ProgressBar.create(progress_parameters)
    #matching products to their categories and categories to their groups
    groups.zip(categories_blocks).map do |group_node, categories_block|
      group = create_group(group_node)
      categories_block.xpath("./li/div[@class='i']").map do |category_node|
        category = group.categories.create(category_parameters(category_node))
        categories_bar.increment
        create_category_products(category,category_node)
      end
    end
    stop_time = Time.new
    categories_bar.finish
    #echo result information
    results(stop_time,start_time)
  end

  private

  #creating groups in Groups table
  def create_group(group_node)
    name_ru = group_node.text.delete("0-9")
    Group.create(name_ru: name_ru, name: '')
  end

  #fetching hash parameters of one category
  def category_parameters(category_node)
    url = category_node.xpath("./a[1]/@href").text
    name = url.sub(URL,'').delete('/')
    name_ru = category_node.xpath("./a[last()]").text
    is_new = category_node.xpath("./a[2]/img[@class='img_new']").any?
    { name: name, name_ru: name_ru, url: url, is_new: is_new }
  end

 #creating all products of a category
  def create_category_products(category,category_node)
    products_page_url = category_node.xpath("./a[1]/@href").text
    while products_page_url
      html_product = Nokogiri::HTML(open(products_page_url))
      html_product.xpath("//tr/td[@class='pdescr']").map do |product_node|
        category.products.create(product_parameters(product_node))
      end
      products_page_url = check_next(html_product)
    end
  end

  #fetching hash parameters of one product
  def product_parameters(product_node)
    url = URL + product_node.xpath("./strong/a/@href").text
    name = product_node.xpath("./strong/a").text.delete("\n" " ")
    image_url = product_node.xpath("../td[@class='pimage']/a/img/@src").text
    { url: url, name: name, image_url: image_url }
  end

  #checking if there is a next product page in the same category
  def check_next(products_page)
    xnext = "//td[@align='right']/strong/a[contains(text(), 'Следующие')]/@href"
    next_url = products_page.xpath(xnext).text
    next_products_page_url = if next_url != ''
      URL + '/' + next_url
    end || false
    next_products_page_url
  end
  
  #calculating parsing time and amount of fetched objects
  def results(stop,start)
    hours = stop.hour - start.hour
    mins = stop.min - start.min
    secs = stop.sec - start.sec
    (mins = mins + 60) && (hours = hours - 1) if mins < 0
    (secs = secs + 60) && (mins = mins - 1) if secs < 0
    puts "Done in #{hours}:#{mins}:#{secs}"
    puts "Got: #{Group.count} groups, #{Category.count} categories, #{Product.count} products"
  end
 
end
