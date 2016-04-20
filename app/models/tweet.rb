require 'oauth'
require 'json'
require 'open-uri'
require 'net/http'
require 'uri'
require 'httpclient'

# require 'wombat'
# require 'open_uri_redirections'

class Tweet < ActiveRecord::Base
  attr_accessible :handle, :message, :query_id, :tweet_id, :tweeted_on
  belongs_to :query
  has_many :leads

  def parse_url(full_url)

    full_url.slice!("https://attendee.gotowebinar.com")
    Wombat.crawl do
      base_url "https://attendee.gotowebinar.com"
      path full_url
      headline "xpath=//a"
      title "xpath=//h2"
      #subheading "css=p.subheading"
      #what_is "css=.teaser h3", :list
      # links do
        #   explore 'xpath=//*[@id="wrapper"]/div[1]/div/ul/li[1]/a' do |e|
        #     e.gsub(/Explore/, "Love")
        #   end

        # search 'css=.search'
        #features 'css=.features'
        #blog 'css=.blog'
      # end
    end
  end

  def get_abs_url(url)
    # $stderr.reopen("err", "w")
    # open(url)
    open(url, :allow_redirections => :safe) do |resp|
      # open(url) do |resp|
      resp.base_uri.to_s
    end
  end

  def parse_tweet
    # ADD CODE TO ITERATE THROUGH EACH TWEET AND PRINT ITS TEXT
    unless self.nil?
      # name = tweet["user"]["name"]
      text = self.message
      puts text

      strings = text.split
      strings.each do |string|
        if string =~ /http/
          begin
            full_url = self.get_abs_url(string)
            puts full_url
            if full_url =~ /register|rt/
              puts parse_url(full_url)
              res = parse_url(full_url)
              if (res["headline"] =~ /@/ and Lead.find_by_link(string).nil?)
                puts "!!!!!!!!!!!!!!!!!!!!!1"
                Lead.create(:email=>res["headline"], :link=>string, :tweet_id=>self.id, :type_cd=>"", :webinar_title=>res["title"])
                # CSV.open("twitter_emal.csv", "a") do |csv|
                #   csv << [string, res]
                # end
              else Lead.create(:link=>string, :tweet_id=>self.id, :type_cd=>"")
              end
            end
          rescue
          end


          # puts if(full_url =~ /rigister/)
        end
      end

      puts "================================="
    end
  end

  def self.parse_parse_tweet
    Tweet.all.each do |tweet|
      if tweet.leads.== []
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~``"
        tweet.parse_tweet
      end
    end
  end
end
