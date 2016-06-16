#!/usr/bin/env ruby
# encoding: utf-8

require 'natto'
require 'nokogiri'
require 'open-uri'# URLにアクセスするためのライブラリの読み込み
require 'csv'

# text = '10日放送の「中居正広のミになる図書館」（テレビ朝日系）で、SMAPの中居正広が、篠原信一の過去の勘違いを明かす一幕があった。'
# text += '京都の王道スポットといえば、言わずと知れた金閣寺です。正式名称を鹿苑寺といいますが、舎利殿「金閣」が特に有名なため一般的に金閣寺と呼ばれています。黄金に輝くその姿に魅了され、国内外から大勢の観光客が訪れます。ソマリノロバ'
# #nm = Natto::MeCab.new({:dicdir => '/usr/local/lib/mecab/dic/mecab-ipadic-neologd/'})
# nm = Natto::MeCab.new()
# nm.parse(text).each_line{ |l| puts l }


# nm.parse(text) do |n|
#   puts "#{n.surface}\t#{n.feature}"
# end
# puts '-----------' * 10


# url = 'http://www.yahoo.co.jp/'# スクレイピング先のURL
# charset = nil
# html = open(url) do |f|
#   charset = f.charset # 文字種別を取得
#   f.read # htmlを読み込んで変数htmlに渡す
# end

# # htmlをパース(解析)してオブジェクトを生成
# doc = Nokogiri::HTML.parse(html, nil, charset)
# # タイトルを表示
# p doc.title

3.times{puts ''}

file_name = 'all.csv'
file_name = 'mecab-user-dict-seed.20160613.csv'
file_name = ARGV[0] if ARGV[0]
  
table = CSV.read(file_name)

# area = table.select{ |line| line[6] == '地域'}.size
# puts area
# area.each{ |x| p x}

#アルテム・トカチェンコ,1289,1289,-17394,5名詞,6固有名詞,7人名,8一般,*,*,アルテム・トカチェンコ,アルテムトカチェンコ,アルテムトカチェンコ

category = table.collect{|row| [row[4],row[5],row[6],row[7],row[8]]}
count = category.inject(Hash.new(0)){ |cnt,item| cnt[item] += 1; cnt}
count.each{ |key,val| puts "#{key} : #{val}"}

category.uniq.each{ |item| p item }

