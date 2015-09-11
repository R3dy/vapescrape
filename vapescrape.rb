#!/usr/bin/env ruby
require 'net/https'
require 'nokogiri'
require 'pry'
require 'optparse'

@baseurl = "https://www.vapeabout.com/vape-store.php?id="
@options = {}
args = OptionParser.new do |opts|
  opts.banner = "Vapescrape.rb VERSION: 0.1 - UPDATED: 9/11/2015\r\n"
  opts.banner += "Usage: ./vapescrape.rb > output.csv\r\n\r\n"
  opts.on("-v", "--verbose", "Enabled verbose output\r\n\r\n") { |v| @options[:verbose] = true }
end
args.parse!(ARGV)

def fetch_url(url, id)
  puts "trying #{url + id.to_s}" if @options[:verbose]
  uri = URI.parse(url + id.to_s)
  if uri.class == URI::HTTPS
    begin
      response = Net::HTTP.get_response(uri)
      page = Nokogiri::HTML(response.body)
      return if page.title.nil?
      shop = page.css('div.shopinfo').css('span').map(&:text)
      shop.each { |x| puts x.chomp + "\t" }
    rescue
      binding.pry
      return
    end
  end
end

(1..10000).each do |id|
  fetch_url(@baseurl, id)
end