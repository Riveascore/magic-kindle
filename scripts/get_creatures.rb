require 'open-uri'
require 'nokogiri'
require 'highline/import'

def get_cards(url_query, file_name = "default.html")
	magic_prefix = "http://magiccards.info/"
	url_prefix = "http://magiccards.info/query?q=t%3A%22legendary%22&s=cname&v=card&p="
	html_file_path = "html/#{file_name}"
	start_page = 29
	end_page = 33

	css_link = %(<link rel="stylesheet" href="magic_cards.css">)


	table_container_selector = 'table[style="margin: 0 0 0.5em 0;"]'
	img_selector = 'tr > td[width="312"] > img'

	final_html = %(#{css_link}\n<table>)

	all_images = []

	page_range = (start_page..end_page).to_a

	page_range.each { |page_number| 
		full_url = "#{url_prefix}#{page_number}"

		opened_url_file = open(full_url)
		html_document = Nokogiri::HTML(opened_url_file)

		images_on_page = html_document.css(table_container_selector).css(img_selector)
		all_images << format_images(images_on_page)
	}

	create_table(all_images, final_html)

	File.open(html_file_path, 'w') { |file|
		file.write(final_html)
	}
end

def create_table(images, html_string)
	all_images.each_slice(2) do |img_row|
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

def get_number_of_pages(nokogiri_html)
	first_table = nokogiri_html.css('body > table').first
	number_of_cards_text = first_table.css('td[align="right"][width="25%"]').text()
	puts number_of_cards_text
	# $('body > table').eq(1).find('td[align="right"][width="25%"]').text()
end

def prompts_and_responses
	input = ask "Enter Search:"
end