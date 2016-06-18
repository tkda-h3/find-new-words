#!/usr/bin/env ruby
# encoding: UTF-8

require 'open-uri'
require 'nokogiri'
require 'uri'
require 'openssl'
require 'kconv'


def nokogiri_document(url)
  begin
    url = URI.escape(url)  
    html = open(url, "r:binary").read
    doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')
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
  rescue Errno::ECONNRESET => e
    STDERR.puts e
    return nil
  rescue SocketError => e
    STDERR.puts e
    return nil    
  end
end


