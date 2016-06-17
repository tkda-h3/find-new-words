#!/usr/bin/env ruby
# encoding: utf-8
require './mname_dot_jp.rb'

dict_words_file = ARGV[0]

url = 'https://mnamae.jp/'
ans = MnamaeDotJp.new(url).execute(dict_words_file)

File.open(ARGV[1],'w') do |f|
  ans.each{|pair| f.puts pair.join("\t")}
end


