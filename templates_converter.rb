require 'rubygems'
require 'nokogiri'

puts "Convertendo template...\n"

flag = true
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
        if(flag)
            csstags << "<%= #{new_el} %>"
            assetsprecompilepaths << "Rails.application.config.assets.precompile += %w(#{href})"
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
            if(flag)
                javascripttags << "<%= #{new_el} %>"
                assetsprecompilepaths << "Rails.application.config.assets.precompile += %w (#{source})"
            end
        end
    end
    
    puts "\nCole os conteúdos do arquivo body.html.erb na index.html.erb (sua página root), o footer num layout _footer.html.erb e de render nele no application.html.erb. Mesma coisa pro _nav.html.erb \n\n"
    
    markup.css('body').each do |el_body|
        new_body = el_body.to_html.gsub(/url\((.+)\)/) do
        "url(&lt;%= asset_path #{$1} %&gt;)"
    end.gsub(/&lt;/,"<").gsub(/&gt;/,">").gsub(/<%= javascript_include_tag (.+)/,"").gsub(/<body(.+)/,"").gsub("</body>","")
        File.open("./bodys/#{filename}.erb", "w") {|f| f.write(new_body) }
    end
    markup.css('footer').each do |el_footer|
        new_footer = el_footer.to_html.gsub(/&lt;/,"<").gsub(/&gt;/,">")
        File.open("./footers/#{filename}.erb", "w") {|f| f.write(new_footer) }
    end

    markup.css('nav').each_with_index do |el_nav,idx|
        new_nav = el_nav.to_html.gsub(/&lt;/,"<").gsub(/&gt;/,">")
        File.open("./navs/nav_#{idx}_#{filename}.erb", "w") {|f| f.write(new_nav) }
    end
    #markup.to_html.gsub(/url\((.+)\)/) do
    #    "url(&lt;%= #{$1} %&gt;)"
    #end
    new_doc = markup.to_html.gsub(/url\((.+)\)/) do
        "url(&lt;%= asset_path #{$1} %&gt;)"
    end.gsub(/&lt;/,"<").gsub(/&gt;/,">")
    # .gsub("background-image: url\((.+)\).","background-image: url(&lt;% \0 %&gt;)")
    
    File.open("#{filename}.erb", "w") {|f| f.write(new_doc) }

    # flag = false
    puts "#{filename} convertido."
end

puts "Cole isto entre as tags <head></head> do seu application.html.erb\n\n"
puts csstags.uniq 
puts "\n"
puts "Cole isto no final da tag <body> do seu application.html.erb, após o <%= yield %>\n\n"
puts javascripttags.uniq
puts "\n"
puts "Cole isto no arquivo assets.rb\n\n"
puts assetsprecompilepaths.uniq
puts "Rails.application.config.assets.precompile += %w(*.jpg *.png)"
puts "\n"
puts "DETALHE: IGNORE TODOS OS PATHS COM HTTP/HTTPS, VOLTE ELES PARA O ORIGINAL (POR EXEMPLO SCRIPT TAG OU LINK TAG) E NAO COLOQUE ELES NO ASSETS.RB. VERIFIQUE TODOS OS STYLESHEET_LINK_TAG DE FAVICON.ICO E TIRE"
puts "Template convertido"