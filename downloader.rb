require "rubygems"
require "simple-rss"
require "open-uri"
require 'net/http'

MINUTES = 5
done = false

while !done

  puts "Downloading feed..."
  rss = SimpleRSS.parse open("http://tvrss.net/feed/eztv/")

  rss.items.select { |i| /apprentice/ =~ i.title.downcase }.each do |i|
    
    filename = "#{i.title}.torrent"

    unless File.exist?(filename)
      puts "Item found! Downloading..."

      open(filename, "wb") do |file|
        file.write(Net::HTTP.get(URI.parse(i.link)))
      end
    end

    done = true
  end

  puts "Item not found, sleeping for #{MINUTES} minutes"
  sleep 60*MINUTES

end
