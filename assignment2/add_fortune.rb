#!/usr/bin/env ruby
# encoding: utf-8
require 'open-uri'
require 'nokogiri'
require './nokogiri_document_function.rb'

raise "ARGV.size should be 2" if ARGV.size != 2

pairs = File.open(ARGV[0],'r'){ |f| f.readlines.collect{ |x| x.strip.split("\t")}}

contents = Hash.new #画数をkey 運勢説明をvalue
cycle = 80 #総画数の運勢の周期
doc = nokogiri_document('http://seimeihandan-yamainunohime.blogspot.jp/p/180.html')

doc.css('#post-body-1378502357946382554 > div:nth-child(1) > div > table tr').each do |tr|
  content = tr.css('td').collect{ |td| td.inner_text.strip}
  kakusuu = content[0].tr('０-９','0-9').to_i 
  contents[ kakusuu % cycle] = content[-1] if kakusuu <= cycle #81画を除くため
end

meta_array = pairs.collect{|pair| pair << contents[pair[1].to_i % cycle]} #名前の総画数と運勢をメタ情報としてもつ。size==3のArrayを要素とする多重Array
File.open(ARGV[1],"w") do |f| 
  meta_array.each{|pair| f.puts pair.join("\t")}
end
