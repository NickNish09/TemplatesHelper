require 'rubygems'
require 'nokogiri'

puts "Convertendo template..."

doc = File.open("index.html")

markup = Nokogiri::HTML.parse(doc)

markup.css('img').each do |el|
  source = el.get_attribute('src')
  classe = el.get_attribute('class')
  new_el = " image_tag \"#{source}\", class: \"#{classe}\" ".to_s
  el.replace "&lt;%= #{new_el} %&gt;"
end

markup.css('link').each do |el|
    href = el.get_attribute('href')
    new_el = " stylesheet_link_tag \"#{href}\" ".to_s
    el.replace "&lt;%= #{new_el} %&gt;"
end

markup.css('script').each do |el|
    if(el.get_attribute('src').nil?)
    else
        source = el.get_attribute('src')
        new_el = " javascript_include_tag \"#{source}\" ".to_s
        el.replace "&lt;%= #{new_el} %&gt;"
    end
end

new_doc = markup.to_html.gsub(/&lt;/,"<").gsub(/&gt;/,">")


File.open("index.html.erb", "w") {|f| f.write(new_doc) }


puts "Template convertido"