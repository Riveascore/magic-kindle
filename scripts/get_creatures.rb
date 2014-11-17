require 'open-uri'
require 'nokogiri'
require 'highline/import'

def get_cards
	# search_query = ask "Enter Search Params:"
	# file_name = ask "Enter a Filename"
	search_query = ""; file_name = ""

	magic_prefix = "http://magiccards.info/"

	file_name = file_name.empty? ? "default.html" : file_name.to_s

	url_query = search_query.empty? ? "http://magiccards.info/query?q=t%3A%22legendary+creature%22+c%21wb&v=card&s=cname" : search_query.to_s
	url_prefix = "#{url_query}&p="

	# html_file_path = "../html/#{file_name}"
	html_file_path = "html/#{file_name}"
	start_page = 1
	end_page = 1

	css_link = %(<link rel="stylesheet" href="magic_cards.css">)


	table_container_selector = 'table[style="margin: 0 0 0.5em 0;"]'
	img_selector = 'tr > td[width="312"] > img'

	final_html = %(#{css_link}\n<table>)

	all_images = []


	num_pages = get_number_of_pages("#{url_prefix}#{1}")
	page_range = (start_page..num_pages).to_a

	page_range.each { |page_number| 
		full_url = "#{url_prefix}#{page_number}"

		opened_url_file = open(full_url)
		html_document = Nokogiri::HTML(opened_url_file)

		images_on_page = html_document.css(table_container_selector).css(img_selector)
		format_images(images_on_page).each { |img| all_images << img }
	}

	create_table(all_images, final_html)

	File.open(html_file_path, 'w') { |file|
		file.write(final_html)
	}
end

def create_table(images, html_string)
	images.each_slice(2) do |img_row|
		html_string << %(<tr>)
		img_row.each do |img|
			html_string << %(<td>#{img}</td>)
		end
		html_string << %(</tr>)
	end
	html_string << %(</table>)

	return html_string
end

def format_images(images)
	return_images = []
	images.each_with_index { |image, index| 
		image.attributes['width'].value = "250"
		image.attributes['height'].value = "357"

		return_images << image
	}	
	return return_images
end

def get_number_of_pages(url)
	url_file = open(url)
	nokogiri_html = Nokogiri::HTML(url_file)

	second_table = nokogiri_html.css('body > table')[1]
	number_of_cards_text = second_table.css('td[align="right"][width="25%"]')
	number_of_cards = number_of_cards_text.text.strip.sub(" cards", "").to_i

	number_of_pages = number_of_cards / 20
	if number_of_cards % 20 != 0
		number_of_pages += 1
	end
	return number_of_pages
end