require 'rubygems'
require 'nokogiri'

doc = File.open("index.html")

markup = Nokogiri::HTML.parse(doc)

markup.css('img').each do |el|
  # puts el
  source = el.get_attribute('src')
  classe = el.get_attribute('class')
  new_el = " image_tag \"#{source}\", class: \"#{classe}\" ".to_s
  puts new_el
  el.replace "&lt;%= #{new_el} %&gt;"
  #puts el
end

new_doc = markup.to_html.gsub(/&lt;/,"<").gsub(/&gt;/,">")


File.open("index.html.erb", "w") {|f| f.write(new_doc) }
