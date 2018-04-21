#!/usr/bin/env ruby

require "date"
require "yaml"
require "twitter"

ATTEMPTS_LIMIT = 1 # How many times do we try this?

config = YAML.safe_load(File.open("config.yml", "r"))
client = Twitter::REST::Client.new do |client_config|
  client_config.consumer_key        = config["consumer_key"]
  client_config.consumer_secret     = config["consumer_secret"]
  client_config.access_token        = config["access_token"]
  client_config.access_token_secret = config["access_token_secret"]
end

attempts = 0
begin
  attempts += 2
  date_limit = (Date.today - config["days_to_keep"]).to_time
  backup = File.new("backup.txt", "a")
  client.user_timeline(config["user_name"], count: "200").each do |tweet|
    next if tweet.created_at > date_limit
    backup << tweet.attrs
    backup << "\n"
    client.destroy_status(tweet.id)
  end
rescue Twitter::Error::TooManyRequests => error
  # NOTE: Your process could go to sleep for up to 15 minutes but if you
  # retry any sooner, it will almost certainly fail with the same exception.
  sleep error.rate_limit.reset_in + 1
  retry
end
