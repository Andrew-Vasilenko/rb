require 'curb'
require 'nokogiri'
require 'csv'

def extract(url, fileName)
	puts "Scrapping " + url + "\n..."
	httpRequest = Curl.get(url)
	html = httpRequest.body_str
	parsed_html = Nokogiri::HTML(html)

	productLinks = parsed_html.xpath('//div[@class="product-desc display_sd"]/a/@href')

	productLinks.each { |link|
    	productHttpRequest = Curl.get(link.to_s)
    	productHtml = productHttpRequest.body_str
    	parsed_productHtml = Nokogiri::HTML(productHtml)

    	productTitle = (parsed_productHtml.xpath('//h1[@class="product_main_name"]/text()')).to_s
    	productImage = (parsed_productHtml.xpath('//span[@id="view_full_size"]/img/@src')).to_s    	

    	productAttributesNames = parsed_productHtml.xpath('//ul[@class="attribute_radio_list pundaline-variations"]//li//label/span[@class="radio_label"]')
    	productAttributesPrices = parsed_productHtml.xpath('//ul[@class="attribute_radio_list pundaline-variations"]//li//label/span[@class="price_comb"]/text()')

    	i = 0
    	productAttributesNames.each { |li|
    		attributeName = li.xpath('text()').to_s
    		productName = (productTitle.gsub('&amp;', '&') + " " + attributeName)
    		productPrice = productAttributesPrices[i].to_s

    		CSV.open(fileName + ".csv", "a+") do |csv|
				csv << [productName, productPrice, productImage]
			end

    		i += 1	
    	}
	}


	nextPageLink = parsed_html.xpath('//link[@rel="next"]/@href')
	unless nextPageLink.empty?
		puts "Page scrapping finished successfully"
  		puts "Link to the next page found: " + nextPageLink.to_s
  		begin
  			extract(nextPageLink.to_s, fileName)
  		rescue
  			puts "Somehow connection error occurred. Trying to reconnect..."
  			puts "Please wait - 3"
			sleep(1)
			puts "Please wait - 2"
			sleep(1)
			puts "Please wait - 1"
			sleep(1)
			extract(nextPageLink.to_s, fileName)
		end
	else
		puts "No more pages in the category!"
		puts "Category scrapping finished successfully!"
	end
end




puts "Enter category url:"
categoryUrl = gets.chomp
puts "Enter file name (will be saved as CSV):"
fileName = gets.chomp

CSV.open(fileName + ".csv", "a+") do |csv|
	csv << ["Name", "Price", "Image"]
end

extract(categoryUrl.to_s, fileName.to_s)



# https://www.petsonic.com/snacks-huesos-para-perros/
# https://www.petsonic.com/tienda-perros/