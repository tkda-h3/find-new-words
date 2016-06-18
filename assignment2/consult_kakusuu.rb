#!/usr/bin/env ruby
# encoding: utf-8

require 'open-uri'
require 'nokogiri'
require 'addressable/uri'
require 'uri'
require 'kconv'
require 'parallel'
require 'openssl'
require './nokogiri_document_function.rb'

raise "ARGV.size should be 2" if ARGV.size != 2

def get_hk_hash
  #hiragana katakana Hash 但し濁点、半濁点、小さい字は含まない
  #文字をkey,画数をvalue
  doc = nokogiri_document('http://goodname.jp/kakusu10.html')
  strs = Array.new
  doc.css('#main > section > p')[1..-1].reject{|p| p.key?('align')}.each do |p|
    strs << p.inner_text.gsub(/　/,"\s")
  end
  hk_hash = Hash[*(strs.join("\s").split("\s").collect{|s| s.tr('０-９','0-9')})]
  hk_hash.each{|k,v| hk_hash[k] = v.to_i}
  return hk_hash
end

hk_hash = get_hk_hash
ans = Array.new
words = File.open(ARGV[0],'r'){ |f| f.readlines.collect{|l| l.strip}}

#words.each do |word|
Parallel.each(words, :in_threads => 10) do |word|
  no_found_flag = false
  kakusuu_array = Array.new
  for i in 0...word.size
    if /\p{hiragana}|\p{katakana}/ =~ word[i] #平仮名orカタカナ
      if hk_hash.key?(word[i])
        kakusuu_array << hk_hash[word[i]].to_i
        next
      else
        STDERR.puts "登録されていない平仮名・カタカナです。"
        no_found_flag = true
        break
      end
    end
    kanji = word[i]
    uri = Addressable::URI.parse('http://kanji.jitenon.jp/cat/search.php')
    uri.query_values = {getdata: kanji, search: 'match', page: '1'}
    search = URI.unescape(uri.to_s)
    doc = nokogiri_document(search)
    if doc.nil?
      puts "#{search}にアクセス失敗"
      no_found_flag = true
      break      
    end
    link = doc.css('#main2 > table a')#.first['href']
    if link.empty? #漢字辞典にない文字。検索結果0
      STDERR.puts "検索結果なし---#{word[i]}---"
      no_found_flag = true
      break
    else
      link = link.first['href']
      doc = nokogiri_document(link)
      if doc.nil?
        puts "#{link}にアクセス失敗"
        no_found_flag = true
        break      
      end
      str = doc.xpath('//*[@id="kanjiright"]/table/tr[3]/td/a')#[0]['href']
      if not str.empty?
        /(\d+)画$/ =~ str[0].inner_text.tr('０-９','0-9')
        kakusuu = $1.to_i
        kakusuu_array << kakusuu
      end
    end
  end

  if no_found_flag
    STDERR.puts "#{word}は検索できない文字を含みます。"
    next
  else
    sum = kakusuu_array.inject(0){|sum,n| sum + n}
    ans << [word,sum]
    #p "#{word}#{kakusuu_array}の総画数は#{sum}である。"
  end
  #puts "合計#{ans.size}  "+"★"*(ans.size/300) if ans.size % 300 == 0
end

File.open(ARGV[1],'w') do |f|
  ans.each{ |x| f.puts x.join("\t")}
end




