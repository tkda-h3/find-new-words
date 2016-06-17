#!/usr/bin/env ruby
# encoding: utf-8
require 'open-uri'
require 'nokogiri'
require 'addressable/uri'
require 'csv'
require 'parallel'

class Site
  def initialize(main_url,debug = false)
    @main_url = main_url
    @debug = debug
  end
  
  def nokogiri_document(url)
    begin
      url = URI.escape(url)  
      charset = nil
      html = open(url) do |f| 
        charset = f.charset
        f.read
      end
      doc = Nokogiri::HTML.parse(html, nil, charset)
      return doc
    rescue OpenURI::HTTPError => e
      STDERR.puts e
      return nil
    rescue Timeout::Error => e
      STDERR.puts e
      return nil
    rescue Errno::ETIMEDOUT => e
      STDERR.puts e
      return nil
    end
  end

  def get_target_urls(main_url)
    #メインページなどからスクレイピングするurl一覧をArrayでreturn
    raise "call Abstract class method(method : get_target_urls)"
  end

  def get_pairs(urls)
    #urls : Array of url    
    raise "call Abstract class method(method : get_pairs)"
  end

  def select_new_words(crawl_words)
    dict_words = File.open("name.log", "r") do |f| # 人名,名に一致する単語が改行区切りで羅列
      hash = Hash.new
      f.readlines.collect{|x| x.strip}.each{ |x| hash[x] = true} # 次でkeyの存在を確かめることが目的なのでHashのvalueはなんでも良い
      hash
    end
    new_words = crawl_words.reject{ |w| dict_words.key?(w[0])}
    return new_words
  end

  def execute()
      urls = self.get_target_urls(@main_url)
      pairs = self.get_pairs(urls)
      st = Time.now
      new_words = self.select_new_words(pairs)
      en = Time.now
      puts "#{en-st}[sec]"
      return new_words

  end
end

class MnamaeDotJp < Site
  def get_target_urls(main_url)
    name_list_doc = self.nokogiri_document(main_url)
    return Array.new if name_list_doc.nil?
    links = Array.new # 名前のprefixごとのurlを取得
    name_list_doc.css('#whole_body > div:nth-child(6) > div.unit-80.t_panel a').each do |link|
      url = URI.join(main_url,URI.escape(link['href'])).to_s
      #  puts url
      links << url
    end
    links = links[0...8] if @debug
    return links
  end

  def get_pairs(urls)
    ans = Array.new
    Parallel.each(urls, :in_threads => 5) do |link|
    #urls.each do |link|
      doc = self.nokogiri_document(link)
      next if doc.nil?
      insert_index = link.index(/\.html/)
      navi_nodes = doc.css('ul.pagination.forpc li a')
      if navi_nodes.empty?
        navi_page_num = 1
      else
        /.*?_(\d+)\.html$/ =~ navi_nodes[-2][:href] #get the number of navigation pages
        navi_page_num = $1.to_i + 1
        navi_page_num = navi_page_num/5 + 1  if @debug
      end
      navi_page_num.times do |i|
        url = link[0...insert_index] + "_#{i}" + link[insert_index..-1]
        doc = self.nokogiri_document(url)
        next if doc.nil?
        Parallel.each(doc.css('#listbody tr'),:in_threads => 15) do |tr| 
          #doc.css('#listbody tr').each do |tr|
          pair = tr.css('td')[0..1].collect{|x| x.inner_text.gsub(/(^(\s|　| )+)|((\s|　| )+$)/, '').strip}.reverse# Array Object [名前,読み方]
          pair[1] = ans[-1][1] if pair[1].empty?
          ans << pair
        end
      end
      puts "収集したデータの数今のところは#{ans.size}です"
    end
    puts "最終的に#{ans.size}個のデータを取得しました"
    return ans
  end
end

url = 'https://mnamae.jp/'
ans = MnamaeDotJp.new(url).execute

puts "新語は#{ans.size}個発見できました"

File.open('new_words_and_how_to_read.txt','w') do |f|
  ans.each{|pair| f.puts pair.join("\t")}
end


#ans.each{|w| p w}

