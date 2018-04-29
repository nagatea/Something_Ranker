require "twitter"
require "dotenv"

Dotenv.load

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["MY_CONSUMER_KEY"]
  config.consumer_secret     = ENV["MY_CONSUMER_SECRET"]
  config.access_token        = ENV["MY_ACCESS_TOKEN"]
  config.access_token_secret = ENV["MY_ACCESS_TOKEN_SECRET"]
end

def tweet_time(id)
  time = Time.at(((id.to_i >> 22) + 1288834974657) / 1000.0).strftime("%Y-%m-%d %H:%M:%S.%L")
  return time
end

query = "花園たえ"

hanazono = []

client.search(query, result_type: "recent",  exclude: "retweets").each do |tweet|
  next if tweet.text != "花園たえ"
  time = tweet_time(tweet.id).to_s
  break if time[0..9] != Date.today.strftime("%Y-%m-%d") && time[0..15] != (Date.today - 1).strftime("%Y-%m-%d 23:59")
  hanazono.push(tweet)
end

i = 0

ranking = []
ranking_fly = ["以下フライング\n"]

hanazono.reverse!.each do |tweet|
  time = tweet_time(tweet.id).to_s
  via = "via: #{tweet.source.to_s.match(/>(.+)</)[1]}"
  flying = time[0..15] == (Date.today - 1).strftime("%Y-%m-%d 23:59")
  if flying #フライング
    ranking_fly.push("#{tweet.user.name}(@#{tweet.user.screen_name})\n#{time}\n#{via}\n\n")
  else
    i += 1
    hantei = "#{i}位:"
    ranking.push("#{hantei} #{tweet.user.name}(@#{tweet.user.screen_name})\n#{time}\n#{via}\n\n")    
  end
end

ranking_fly[0] = "フライングなし" if ranking_fly[1] == nil

client.create_direct_message('RonRonMonday', ranking.join + ranking_fly.join)

