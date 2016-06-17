#!/usr/bin/env ruby
# encoding: utf-8
require 'open-uri'
require 'nokogiri'
require 'addressable/uri'
require 'csv'
require 'parallel'

debug = false#true

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

main_url = 'https://mnamae.jp/'
name_list_doc = nokogiri_document(main_url)
links = Array.new # 名前のprefixごとのurlを取得
name_list_doc.css('#whole_body > div:nth-child(6) > div.unit-80.t_panel a').each do |link|
  url = URI.join(main_url,URI.escape(link['href'])).to_s
  #  puts url
  links << url
end

links = links[0...5] if debug

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
    navi_page_num = navi_page_num/3 + 1  if debug
  end

  navi_page_num.times do |i|
    url = link[0...insert_index] + "_#{i}" + link[insert_index..-1]
    doc = nokogiri_document(url)
    Parallel.each(doc.css('#listbody tr'),:in_threads => 15) do |tr| 
#    doc.css('#listbody tr').each do |tr|
      pair = tr.css('td')[0..1].collect{|x| x.inner_text.gsub(/(^(\s|　| )+)|((\s|　| )+$)/, '').strip}.reverse# Array Object [名前,読み方]
      pair[1] = ans[-1][1] if pair[1].empty?
      ans << pair
    end
  end
  puts "収集したデータの数今のところは#{ans.size}です"
end

ans.each{ |x| p x}
ans.each do |pair|
  if pair[1].empty?
    puts 'pair[1] is empty'
    exit
  end
end

# CSV.open('result.csv','w') do |test|
#   ans.each{|pair| test.puts pair}
# end

words = File.open("name.log", "r") do |f| # 人名,名に一致する単語が改行区切りで羅列
  f.readlines.collect{|x| x.strip}
end
puts '-----wwww-----wwwwww------'
puts words.size
puts '-----wwww-----wwwwww------'


ans= ans.reject{|w| words.include?(w[0])}#Hashをつかってもっと賢く
p ans
puts ans.size

CSV.open('new_words_and_how_to_read.csv','w') do |f|
  ans.each{|pair| f.puts pair}
end
