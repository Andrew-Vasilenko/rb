require 'curb'
require 'nokogiri'
require 'csv'

scannedPages = 0

def extract(url, fileName)
	puts "scrapping " + url + "\n..."
	httpRequest = Curl.get(url)
	html = httpRequest.body_str
	parsed_html = Nokogiri::HTML(html)

	productLinks = parsed_html.xpath('//div[@class="product-desc display_sd"]/a/@href')

	productLinks.each { |link|
    	productHttpRequest = Curl.get(link.to_s)
    	productHtml = productHttpRequest.body_str
    	parsed_productHtml = Nokogiri::HTML(productHtml)

    	productTitle = parsed_productHtml.xpath('//h1[@class="product_main_name"]/text()')

    	File.open("out.txt", "a+") {|f| f.write(productTitle, "\n") }

    	

    	productAttributesNames = parsed_productHtml.xpath('//ul[@class="attribute_radio_list pundaline-variations"]//li//label/span[@class="radio_label"]')
    	productAttributesPrices = parsed_productHtml.xpath('//ul[@class="attribute_radio_list pundaline-variations"]//li//label/span[@class="price_comb"]/text()')

    	i = 0
    	productAttributesNames.each { |attributeName|

    		productName = productTitle.to_s + " " + (attributeName.xpath('text()')).to_s
    		productPrice = productAttributesPrices[i].to_s

    		CSV.open(fileName + ".csv", "a+") do |csv|
				csv << [productName, productPrice, "image"]
			end

    		i += 1	
    	}

    	File.open("out.txt", "a+") {|f| f.write("\n\n\n\n\n\n\n\n") }

	}


	nextPageLink = parsed_html.xpath('//link[@rel="next"]/@href')
	unless nextPageLink.empty?
		puts "page scrapping finished successfully"
		puts "Please wait - 3"
		sleep(1)
		puts "Please wait - 2"
		sleep(1)
		puts "Please wait - 1"
		sleep(1)
  		puts "link to the next page found:" + nextPageLink.to_s
  		begin
  			extract(nextPageLink.to_s, fileName)
  		rescue
  			puts "Some connection error occured. Trying to reconnect..."
  			puts "Please wait - 3"
			sleep(1)
			puts "Please wait - 2"
			sleep(1)
			puts "Please wait - 1"
			sleep(1)
			extract(nextPageLink.to_s, fileName)
		end
	end
	puts "No more pages in the category!"
	puts "Category scrapping finished successfully!"
end



# categoryUrl = "https://www.petsonic.com/snacks-huesos-para-perros/"
# https://www.petsonic.com/tienda-perros/
puts "Enter category url:"
categoryUrl = gets.chomp
puts "Enter file name (will be saved as CSV):"
fileName = gets.chomp

CSV.open(fileName + ".csv", "a+") do |csv|
	csv << ["Name", "Price", "Image"]
end

extract(categoryUrl.to_s, fileName.to_s)



