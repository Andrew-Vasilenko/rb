require 'curb'
require 'nokogiri'

def extract(url)
	puts "extract function initiated"
	httpRequest = Curl.get(url)
	html = httpRequest.body_str
	parsed_html = Nokogiri::HTML(html)

	productLinks = parsed_html.xpath('//div[@class="product-desc display_sd"]/a/@href')
	File.open("out.txt", "a+") {|f| f.write(productLinks) }
	File.open("out.txt", "a+") {|f| f.write("          ") }

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



