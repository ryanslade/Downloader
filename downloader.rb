require "rubygems"
require "simple-rss"
require "open-uri"
require 'net/http'

MINUTES = 5
SHOWS = [/apprentice/, /chuck/]
done = false

while !done

  puts "Downloading feed..."
  rss = SimpleRSS.parse open("http://tvrss.net/feed/eztv/")

  rss.items.select { |i| SHOWS.any? { |s| s =~ i.title.downcase } }.each do |i|
    
    filename = "#{i.title}.torrent"

    unless File.exist?(filename)
      puts "Item found! Downloading..."

      open(filename, "wb") do |file|
        file.write(Net::HTTP.get(URI.parse(i.link)))
      end
    end
    
  end

  puts "Sleeping for #{MINUTES} minutes"
  sleep 60*MINUTES

end
