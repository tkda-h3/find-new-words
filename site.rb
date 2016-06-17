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
    rescue OpenSSL::SSL::SSLError => e
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

  def select_new_words(crawl_words,dict_words_file)
    dict_words = File.open(dict_words_file, "r") do |f| # 人名,名に一致する単語が改行区切りで羅列
      hash = Hash.new
      f.readlines.collect{|x| x.strip}.each{ |x| hash[x] = true} # 次でkeyの存在を確かめることが目的なのでHashのvalueはなんでも良い
      hash
    end
    new_words = crawl_words.reject{ |w| dict_words.key?(w[0])}
    return new_words
  end

  def execute(dict_words_file)
      urls = self.get_target_urls(@main_url)
      pairs = self.get_pairs(urls)
      st = Time.now
      new_words = self.select_new_words(pairs,dict_words_file)
      en = Time.now
      puts "#{en-st}[sec]"
      return new_words
  end
end
