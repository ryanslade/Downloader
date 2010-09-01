%w(rubygems rss/1.0 rss/2.0 addressable/uri net/http datamapper).each { |lib| require lib }

FEED_SOURCE = "http://ezrss.it/feed/"
MINUTES = 60
SHOWS = ["eastbound down", "inbetweeners", "modern family", "party down", "breaking bad", "apprentice uk", "30 rock", "gossip girl", "how met your mother", "big bang theory", "entourage", "true blood", "californication", "hung", "bored to death"]
IGNORE = ["720"]

class Show
  include DataMapper::Resource

  property :name, String, :key => true
  property :created_at, DateTime, :default => Proc.new { Time.now.utc }
end

def string_to_regexp(input)
  input.collect { |s| Regexp.new(s.gsub(" ", ".*"), true) }
end

def save_torrent_file(rss_item)
  filename = "#{rss_item.title}.torrent"
  puts "Downloading: #{filename}"
  open(filename, "wb") { |f| f.write(Net::HTTP.get(URI.parse(Addressable::URI.encode(rss_item.link)))) }
  Show.create!(:name => rss_item.title)
end

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/downloaded.db")
DataMapper.auto_upgrade!

shows_regexp = string_to_regexp(SHOWS)
ignore_regexp = string_to_regexp(IGNORE)

while true

  begin
    puts "Downloading feed..."
    rss = RSS::Parser.parse(open(FEED_SOURCE), false)

    rss.items.select { |i| shows_regexp.any? { |s| s =~ i.title.downcase } }.each do |i|
      unless (ignore_regexp.any? { |r| r =~ i.title } || Show.get(i.title))
        save_torrent_file(i)
      end
    end

  rescue Exception => e
    puts "ERROR: #{e.to_s}"
  end

  puts "Sleeping for #{MINUTES} minutes"
  sleep 60*MINUTES

end
