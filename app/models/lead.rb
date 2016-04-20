class Lead < ActiveRecord::Base
  attr_accessible :email, :link, :tweet_id, :type_cd, :webinar_title
  belongs_to :tweet

  scope :not_parsed, :conditions => 'leads.email is null'
  scope :parsed, :conditions => 'leads.email is not null'

  def reparse_email
      begin
        puts "in begin"
        puts self.tweet
        full_url = self.tweet.get_abs_url(self.link)
        puts full_url
        if full_url =~ /register|rt/
          puts "yeeeeeeeeeeeeeeeeees"
          res = self.tweet.parse_url(full_url)
          puts res
          if res["headline"] =~ /@/
            puts "!!!!!!!!!!!!!!!!!!!!!1"
            self.email = res["headline"]
            self.webinar_title = res["title"]
            self.save
            puts "1 more add ==============================================="
            return self
            # Lead.create(:email=>res["headline"], :link=>string, :tweet_id=>self.id, :type_cd=>"", :webinar_title=>res["title"])
            # CSV.open("twitter_emal.csv", "a") do |csv|
            #   csv << [string, res]
            # end
          #else Lead.create(:link=>string, :tweet_id=>self.id, :type_cd=>"")
          end
        end
      rescue
      end
  end

  def self.batch_reparse

    newly = []
    Lead.not_parsed.each do |lead|
      l = lead.reparse_email
      puts l.class
      unless l.nil?
        newly << l
      end
    end
    return newly
  end

end
