require 'twitter'
require 'rubygems'
require 'oauth'
require 'json'
require 'date'

class Query < ActiveRecord::Base
  attr_accessible :handle, :hash_tag, :keywords
  has_many :tweets



  def search_tweet(query)
    puts query
    consumer_key = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET)
    access_token = OAuth::Token.new(ACCESS_KEY, ACCESS_SECRET)

    baseurl = "https://api.twitter.com"
    path = "/1.1/search/tweets.json"

    last_tw_id = Tweet.last.nil? ? '' : Tweet.last.tweet_id.to_i
    puts last_tw_id
    query = URI.encode_www_form(
      "q" => query,
      # "screen_name" => "twitterapi",
      "count" => 100,
      "lang" => 'en',
      "since_id" => ''
    )
    address = URI("#{baseurl}#{path}?#{query}")
    request = Net::HTTP::Get.new address.request_uri

    # Set up HTTP.
    http = Net::HTTP.new address.host, address.port
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    # If you entered your credentials in the first
    # exercise, no need to enter them again here. The
    # ||= operator will only assign these values if
    # # they are not already set.
    #     consumer_key ||= OAuth::Consumer.new "ENTER IN EXERCISE 1", ""
    #     access_token ||= OAuth::Token.new "ENTER IN EXERCISE 1", ""

    # Issue the request.
    request.oauth! http, consumer_key, access_token
    http.start
    response = http.request request

    # Parse and print the Tweet if the response code was 200
    #tweets = nil
    if response.code == '200' then
      tweets = JSON.parse(response.body)["statuses"]
      # puts JSON.pretty_generate(tweets)
      # puts tweets.count
      # puts tweets.class
      # puts tweets["statuses"].class
      #print_timeline(tweets)
      tweets.each do |tweet|
        if Tweet.find_by_tweet_id(tweet["id_str"]).nil?
          t = Tweet.create(:message=> tweet["text"], :handle=>tweet["user"]["id_str"], :tweet_id=>tweet["id_str"], :tweeted_on=>tweet["created_at"], :query_id=>self.id)
          t.parse_tweet
        end
      end
    end
  end

  def generate_query(s, minus)
    today_string = (Date.today - minus).to_s
    query = s + ' until:'+today_string
  end

  def generate_hash
    unless self.hash_tag[0]=='#'
      hash ="#"+ self.hash_tag
    else
      hash =self.hash_tag
    end
    hash
  end

  def generate_handle
    unless self.handle[0]=='@'
      hand ="#"+ self.handle
    else
      hand = self.handle
    end
    hand
  end

  def make_twitter_query(minus=7)
    puts self
    if self.handle.length > 0
      s = generate_handle
    elsif self.hash_tag.length > 0
      s = generate_hash
    else
      s = self.keywords
    end
    (0..minus).to_a.reverse.each do |day|
      q = generate_query(s,day)
      self.search_tweet(q)
    end
  end
end
