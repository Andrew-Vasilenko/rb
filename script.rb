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
    	File.open("out.txt", "a+") {|f| f.write("\n\n") }

    	productAttributesNames = parsed_productHtml.xpath('//ul[@class="attribute_radio_list pundaline-variations"]//li//label/span[@class="radio_label"]')
    	productAttributesPrices = parsed_productHtml.xpath('//ul[@class="attribute_radio_list pundaline-variations"]//li//label/span[@class="price_comb"]/text()')

    	i = 0
    	productAttributesNames.each { |attributeName|    		
    		File.open("out.txt", "a+") {|f| f.write(attributeName.xpath('text()'), " - ", productAttributesPrices[i].to_s, "\n\n") }
    		i += 1	
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



