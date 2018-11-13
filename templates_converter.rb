require 'rubygems'
require 'nokogiri'

puts "Convertendo template...\n"

idx = 0
csstags = []
javascripttags = []
assetsprecompilepaths = []

Dir.foreach("#{Dir.pwd}/to_convert") do |filename|
    puts "Convertendo #{filename}..."
    doc = File.open(File.expand_path(filename, "#{File.dirname(__FILE__)}/to_convert"))

    markup = Nokogiri::HTML.parse(doc)
    
    markup.css('img').each do |el|
      source = el.get_attribute('src')
      classe = el.get_attribute('class')
      new_el = "image_tag \"#{source}\", class: \"#{classe}\"".to_s
      el.replace "&lt;%= #{new_el} %&gt;"
    end
    
    markup.css('link').each do |el|
        href = el.get_attribute('href')
        new_el = "stylesheet_link_tag \"#{href}\"".to_s
        el.replace "&lt;%= #{new_el} %&gt;"
        if(idx == 0)
            csstags << "<%= #{new_el} %>"
            assetsprecompilepaths << "Rails.application.config.assets.precompile += %w (#{href})"
        end
        # puts "<%= #{new_el} %>"
    end
    
    markup.css('script').each do |el|
        if(el.get_attribute('src').nil?)
        else
            source = el.get_attribute('src')
            new_el = "javascript_include_tag \"#{source}\"".to_s
            el.replace "&lt;%= #{new_el} %&gt;"
            #puts "<%= #{new_el} %>"
            if(idx == 0)
                javascripttags << "<%= #{new_el} %>"
                assetsprecompilepaths << "Rails.application.config.assets.precompile += %w (#{source})"
            end
        end
    end
    
    puts "\nCole os conteúdos do arquivo body.html.erb na index.html.erb (sua página root) \n\n"
    
    markup.css('body').each do |el_body|
        new_body = el_body.to_html.gsub(/&lt;/,"<").gsub(/&gt;/,">").gsub(/<%= javascript_include_tag (.+)/,"").gsub(/<body(.+)/,"").gsub("</body>","")
        File.open("body_#{filename}.html.erb", "w") {|f| f.write(new_body) }
    end
    
    new_doc = markup.to_html.gsub(/&lt;/,"<").gsub(/&gt;/,">")
    
    File.open("#{filename}.erb", "w") {|f| f.write(new_doc) }

    idx = 1
    puts "#{filename} convertido."
end

puts "Cole isto entre as tags <head></head> do seu application.html.erb\n\n"
puts csstags    
puts "\n"
puts "Cole isto no final da tag <body> do seu application.html.erb, após o <%= yield %>\n\n"
puts javascripttags
puts "\n"
puts "Cole isto no arquivo assets.rb\n\n"
puts assetsprecompilepaths
puts "Rails.application.config.assets.precompile += %w (*.jpg *.png)"
puts "\n"
puts "DETALHE: IGNORE TODOS OS PATHS COM HTTP/HTTPS, VOLTE ELES PARA O ORIGINAL (POR EXEMPLO SCRIPT TAG OU LINK TAG) E NAO COLOQUE ELES NO ASSETS.RB"
puts "Template convertido"