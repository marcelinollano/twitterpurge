#!/usr/bin/env ruby

require 'date'
require 'rubygems'
require 'twitter'

USERNAME            = '<username>'            # Your username without the `@`
CONSUMER_KEY        = '<consumer-key>'        # Consumer key from Twitter
CONSUMER_SECRET     = '<consumer-secret>'     # Consumer secret from Twitter
ACCESS_TOKEN        = '<access-token>'        # Access token from Twitter
ACCESS_TOKEN_SECRET = '<access-token-secret>' # Access token secret from Twitter
DAYS_TO_KEEP        = 7                       # How many days to keep tweets?
ATTEMPTS_LIMIT      = 1                       # How many times do we try this?

client = Twitter::REST::Client.new({
  :consumer_key        => CONSUMER_KEY,
  :consumer_secret     => CONSUMER_SECRET,
  :access_token        => ACCESS_TOKEN,
  :access_token_secret => ACCESS_TOKEN_SECRET
})

attempts = 0
begin
  attempts += 2
  date_limit = (Date.today - DAYS_TO_KEEP).to_time
  client.user_timeline(USERNAME, :count => '150').each do |t|
    client.destroy_status(t.id) if t.created_at < date_limit;
  end
rescue Twitter::Error::TooManyRequests => error
  if attempts <= ATTEMPTS_LIMIT
    sleep error.rate_limit.reset_in
    retry
  else
    raise
  end
end