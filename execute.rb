#!/usr/bin/env ruby
# encoding: utf-8
require './mname_dot_jp.rb'

dict_words_file = ARGV[0]

url = 'https://mnamae.jp/'
ans = MnamaeDotJp.new(url,true).execute(dict_words_file)

puts "新語は#{ans.size}個発見できました"

File.open(ARGV[1],'w') do |f|
  ans.each{|pair| f.puts pair.join("\t")}
end


