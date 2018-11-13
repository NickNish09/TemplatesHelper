require 'rubygems'
require 'nokogiri'

puts "Convertendo template...\n"

doc = File.open("index.html")

markup = Nokogiri::HTML.parse(doc)

markup.css('img').each do |el|
  source = el.get_attribute('src')
  classe = el.get_attribute('class')
  new_el = " image_tag \"#{source}\", class: \"#{classe}\" ".to_s
  el.replace "&lt;%= #{new_el} %&gt;"
end

puts "Cole isto entre as tags <head></head> do seu application.html.erb\n\n"
markup.css('link').each do |el|
    href = el.get_attribute('href')
    new_el = "stylesheet_link_tag \"#{href}\"".to_s
    el.replace "&lt;%= #{new_el} %&gt;"
    puts "<%= #{new_el} %>"
end

puts "\n"
puts "Cole isto no final da tag <body> do seu application.html.erb, após o <%= yield %>\n\n"

markup.css('script').each do |el|
    if(el.get_attribute('src').nil?)
    else
        source = el.get_attribute('src')
        new_el = "javascript_include_tag \"#{source}\"".to_s
        el.replace "&lt;%= #{new_el} %&gt;"
        puts "<%= #{new_el} %>"
    end
end

puts "\nCole os conteúdos do arquivo body.html.erb na index.html.erb (sua página root) \n\n"

markup.css('body').each do |el_body|
    new_body = el_body.to_html.gsub(/&lt;/,"<").gsub(/&gt;/,">").gsub(/<%= javascript_include_tag (.+)/,"").gsub(/<body(.+)/,"").gsub("</body>","")
    File.open("body.html.erb", "w") {|f| f.write(new_body) }
end

new_doc = markup.to_html.gsub(/&lt;/,"<").gsub(/&gt;/,">")

File.open("index.html.erb", "w") {|f| f.write(new_doc) }

puts "\n"
puts "Template convertido"