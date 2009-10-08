%w(rubygems rss/1.0 rss/2.0 open-uri net/http datamapper).each { |lib| require lib }

class Show

  include DataMapper::Resource

  property :name, String, :key => true
  property :created_at, DateTime, :default => Proc.new { Time.now }

end

class Helper

  def self.string_to_regexp(input)
    input.collect { |s| Regexp.new(s.gsub(" ", ".*")) }
  end

  def self.save_torrent_file(rss_item)
    filename = "#{rss_item.title}.torrent"

    puts "Downloading: #{filename}"

    open(filename, "wb") { |f| f.write(Net::HTTP.get(URI.parse(rss_item.link))) }

    Show.create!(:name => rss_item.title)
  end

end

FEED_SOURCE = "http://pipes.yahoo.com/pipes/pipe.run?_id=7aa6281616ea0a8cb27aaa0914f09a76&_render=rss"
MINUTES = 10
SHOWS = ["apprentice uk", "30 rock", "dollhouse", "gossip girl", "how met your mother", "big bang theory", "entourage", "true blood", "californication", "hung", "bored to death", "flash forward"]
IGNORE = ["720"]

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/downloaded.db")
DataMapper.auto_upgrade!

shows_regexp = Helper.string_to_regexp(SHOWS)
ignore_regexp = Helper.string_to_regexp(IGNORE)

while true

  begin
    puts "Downloading feed..."
    rss = RSS::Parser.parse(open(FEED_SOURCE), false)

    rss.items.select { |item| shows_regexp.any? { |s| s =~ item.title.downcase } }.each do |item|
      unless ignore_regexp.any? { |r| r =~ item.title } || Show.get(item.title)
        Helper.save_torrent_file(item)
      end
    end

  rescue Exception => e
    puts "ERROR: #{e.to_s}"
  end

  puts "Sleeping for #{MINUTES} minutes"
  sleep 60*MINUTES

end
