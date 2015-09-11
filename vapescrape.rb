#!/usr/bin/env ruby
require 'net/https'
require 'nokogiri'
require 'pry'

@baseurl = "https://www.vapeabout.com/vape-store.php?id="
@threads = Thread.pool(10)

def fetch_url(url, id)
  puts "trying #{url + id.to_s}"
  uri = URI.parse(url + id.to_s)
  if uri.class == URI::HTTPS
    begin
      http = set_http(uri)
      response = Net::HTTP.get_response(uri)
      page = Nokogiri::HTML(response.body)
      return if page.title.nil?
      shop = page.css('div.shopinfo').css('span').map(&:text)
      shop.each { |x| puts x.chomp + "\t" }
    rescue
      return
    end
  end
end

(1..10000).each do |id|
  fetch_url(@baseurl, id)
end