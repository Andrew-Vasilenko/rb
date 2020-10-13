require 'curb'
require 'nokogiri'

def extract(url)
	puts "extract function initiated"
	httpRequest = Curl.get(url)
	html = httpRequest.body_str
	parsed_html = Nokogiri::HTML(html)

	productLinks = parsed_html.xpath('//div[@class="product-desc display_sd"]/a/@href')

	productLinks.each { |link|
    	productHttpRequest = Curl.get(link.to_s)
    	productHtml = productHttpRequest.body_str
    	parsed_productHtml = Nokogiri::HTML(productHtml)

    	productTitle = parsed_productHtml.xpath('//h1[@class="product_main_name"]/text()')

    	File.open("out.txt", "a+") {|f| f.write(productTitle) }
    	File.open("out.txt", "a+") {|f| f.write("\n") }
    	File.open("out.txt", "a+") {|f| f.write("ATTRIBUTES:") }
    	File.open("out.txt", "a+") {|f| f.write("\n") }

    	productAttributesList = parsed_productHtml.xpath('//ul[@class="attribute_radio_list pundaline-variations"]//li')
    	productVariationsList = parsed_productHtml.xpath('//ul[@class="variation-selector"]//li')


    	productAttributesList.each { |li|
    		attributeName = li.xpath('//span[@class="radio_label"]/text()')
    		attributePrice = li.xpath('//span[@class="price_comb"]/text()')
    		File.open("out.txt", "a+") {|f| f.write(attributeName) }
    		File.open("out.txt", "a+") {|f| f.write(" - ") }
    		File.open("out.txt", "a+") {|f| f.write(attributePrice) }
    		File.open("out.txt", "a+") {|f| f.write("\n") }

    		File.open("out.txt", "a+") {|f| f.write("VARIATIONS:") }
	    	File.open("out.txt", "a+") {|f| f.write("\n") }
	    	
	    	productVariationsList.each { |li|
	    		variationName = li.xpath('./span[@class="variation-name"]/text()')
	    		variationPrice = li.xpath('./span[@class="variation-price"]/text()')
	    		File.open("out.txt", "a+") {|f| f.write(variationName) }
	    		File.open("out.txt", "a+") {|f| f.write(" - ") }
	    		File.open("out.txt", "a+") {|f| f.write(variationPrice) }
	    		File.open("out.txt", "a+") {|f| f.write("\n") }
	    	}

    	}

    	File.open("out.txt", "a+") {|f| f.write("\n\n\n\n\n\n\n\n") }

	}


	nextPageLink = parsed_html.xpath('//link[@rel="next"]/@href')
	unless nextPageLink.empty?
  		puts "next page link found:"
  		puts nextPageLink
  		extract(nextPageLink.to_s)
	end
end



categoryUrl = "https://www.petsonic.com/snacks-huesos-para-perros/"
puts "START:"
extract(categoryUrl)



