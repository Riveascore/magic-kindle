require 'open-uri'
require 'nokogiri'

url_prefix = "http://magiccards.info/query?q=t%3A%22legendary%22&s=cname&v=card&p="
html_file_path = "/tmp/legendary.html"
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
	images_on_page.each_with_index { |image, index| 
		image.attributes['width'].value = "250"
		image.attributes['height'].value = "357"

		all_images << image 
	}
}

all_images.each_slice(2) do |img_row|
	final_html << %(<tr>)
	img_row.each do |img|
		final_html << %(<td>#{img}</td>)
	end
	final_html << %(</tr>)
end
final_html << %(</table>)

File.open(html_file_path, 'w') { |file|
	file.write(final_html)
}

