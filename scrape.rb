#!/usr/bin/env ruby
# encoding: utf-8
require 'open-uri'
require 'nokogiri'
require 'addressable/uri'
require 'csv'
require 'parallel'


def nokogiri_document(url)
  url = URI.escape(url)  
  charset = nil
  html = open(url) do |f| 
    charset = f.charset
    f.read
  end
  doc = Nokogiri::HTML.parse(html, nil, charset)
  return doc
end

root_url = 'https://mnamae.jp/'
name_list_doc = nokogiri_document(root_url)
links = Array.new # 名前のprefixごとのurlを取得
name_list_doc.css('#whole_body > div:nth-child(6) > div.unit-80.t_panel a').each do |link|
  url = URI.join(root_url,URI.escape(link['href'])).to_s
  #  puts url
  links << url
end


ans = Array.new
Parallel.each(links, :in_threads => 20) do |link|
#links.each do |link|
  doc = nokogiri_document(link)
  insert_index = link.index(/\.html/)
  navi_nodes = doc.css('ul.pagination.forpc li a')
  if navi_nodes.empty?
    navi_page_num = 1
  else
    /.*?_(\d+)\.html$/ =~ navi_nodes[-2][:href] #get the number of navigation pages
    navi_page_num = $1.to_i + 1
  end
  # puts link
  # puts navi_page_num
  # puts insert_index
  navi_page_num.times do |i|
    url = link[0...insert_index] + "_#{i}" + link[insert_index..-1]
    doc = nokogiri_document(url)
    Parallel.each(doc.css('#listbody tr'),:in_threads => 15) do |tr| 
#    doc.css('#listbody tr').each do |tr|
      pair = tr.css('td')[0..1].collect{|x| x.inner_text.gsub(/(^(\s|　| )+)|((\s|　| )+$)/, '').strip}# Array Object [名前, 読み方]
      pair[0] = ans[-1][0] if pair[0].empty?
      ans << pair
    end
  end
  puts "収集したデータの数今のところは#{ans.size}です"
end

ans.each do |pair|
  if pair[0].empty?
    puts 'pair[0] is empty'
    exit
  end
end

# CSV.open('result.csv','w') do |test|
#   ans.each{|pair| test.puts pair}
# end




