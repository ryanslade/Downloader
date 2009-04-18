%w(rubygems simple-rss open-uri net/http datamapper).each { |lib| require lib }

class Show
  
  include DataMapper::Resource
  
  property :name, String, :key => true
  property :created_at, DateTime, :default => Proc.new { Time.now }
  
end

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/downloaded.db")
DataMapper.auto_upgrade!

MINUTES = 10
SHOWS = [/apprentice.*uk/, /30.*rock/, /dollhouse/, /gossip.*girl/, /how.*met.*your.*mother.*/]
done = false

while !done

  begin
    puts "Downloading feed..."
    rss = SimpleRSS.parse open("http://tvrss.net/feed/eztv/")

    rss.items.select { |i| SHOWS.any? { |s| s =~ i.title.downcase } }.each do |i|

      filename = "#{i.title}.torrent"

      unless Show.get(i.title)
        puts "Downloading: #{filename}"

        open(filename, "wb") do |file|
          file.write(Net::HTTP.get(URI.parse(i.link)))
        end
        
        Show.create!(:name => i.title)
      end

    end
  rescue Exception => e
    puts "ERROR: #{e.to_s}"
  end

  puts "Sleeping for #{MINUTES} minutes"
  sleep 60*MINUTES

end
