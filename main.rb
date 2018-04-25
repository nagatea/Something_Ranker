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

text = []

hanazono.reverse!.each do |tweet|
  time = tweet_time(tweet.id).to_s
  flying = time[0..15] == (Date.today - 1).strftime("%Y-%m-%d 23:59")
  if flying
    hantei = "フライング"
  else
    i += 1
    hantei = "#{i}位"
  end
  text.push("#{hantei} #{tweet.user.name}(@#{tweet.user.screen_name})\n#{time}\n\n")
end

client.create_direct_message('RonRonMonday', text.join)

