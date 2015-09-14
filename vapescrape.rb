#!/usr/bin/env ruby
begin
  require 'net/https'
  require 'nokogiri'
  require 'pry'
  require 'optparse'
rescue
  puts "error resolving dependencies, make sure to bundle install first"
end

@urltop = "https://thevaporrater.com/page/"
@urlbottom = "/?geodir_search=1&stype=gd_place&s=+&snear&sgeo_lat&sgeo_lon"
@options = {}
@stores = []
args = OptionParser.new do |opts|
  opts.banner = "Vapescrape.rb VERSION: 0.1 - UPDATED: 9/11/2015\r\n"
  opts.banner += "Usage: ./vapescrape.rb > output.csv\r\n\r\n"
  opts.on("-v", "--verbose", "Enabled verbose output\r\n\r\n") { |v| @options[:verbose] = true }
end
args.parse!(ARGV)

def fetch_url(id)
  url = @urltop + id.to_s + @urlbottom
  puts "trying #{url}" if @options[:verbose]
  uri = URI.parse(url)
  if uri.class == URI::HTTPS
    begin
      response = Net::HTTP.get_response(uri)
      page = Nokogiri::HTML(response.body)
      page.css('div.geodir-content').each do |store|
        newstore = Hash.new
        newstore[:name] = store.css('a')[0].attr('title') if store.css('a')[0]
        newstore[:street] = store.css('span')[1].text
        newstore[:city] = store.css('span')[2].text
        newstore[:state] = store.css('span')[3].text
        newstore[:zip] = store.css('span')[4].text
        newstore[:country] = store.css('span')[5].text
        newstore[:phone] = store.css('div')[1].css('a').text
        newstore[:website] = !store.css('div')[2].css('a').empty? ? store.css('div')[2].css('a').attr('href').text : ""
        output = String.new
        newstore.each { |x,v| output << v.chomp + "\t".chomp }
        @stores << output
      end
    rescue StandardError => msg
      puts "#{url}: #{msg}"
      return
    end
  end
end

402.times.each do |id|
  fetch_url(id+1)
end

puts "Name:\tStreet:\tCity:\tState:\tZip:\tCountry:\tPhone:\tWebsite:"
@stores.each { |s| puts s }