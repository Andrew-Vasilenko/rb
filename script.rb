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
    	productPrice = parsed_productHtml.xpath('//span[@id="our_price_display"]/text()')
    	puts productTitle
    	puts productPrice
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



