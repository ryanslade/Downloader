require "rubygems"
require "simple-rss"
require "open-uri"
require 'net/http'

rss = SimpleRSS.parse open("http://tvrss.net/feed/eztv/")

puts rss.channel.title

item = rss.items[0]

open(item.title+".torrent", "wb") { |file|
  file.write(Net::HTTP.get(URI.parse(item.link)))
 }
 