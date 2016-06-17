#!/usr/bin/env ruby
# encoding: utf-8
require './site.rb'


class MnamaeDotJp < Site
  def get_target_urls(main_url)
    name_list_doc = self.nokogiri_document(main_url)
    return Array.new if name_list_doc.nil?
    links = Array.new # 名前のprefixごとのurlを取得
    name_list_doc.css('#whole_body > div:nth-child(6) > div.unit-80.t_panel a').each do |link|
      url = URI.join(main_url,URI.escape(link['href'])).to_s
      links << url
    end
    links = links[0...5] if @debug
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
    end
    return ans
  end
end
