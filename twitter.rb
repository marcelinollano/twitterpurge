#!/usr/local/bin/ruby

require 'date'
require 'rubygems'
require 'twitter'

USERNAME = '<username>'
ATTEMPTS = 1
DAYS     = 5

config = {
  :consumer_key        => "<consumer-key>",
  :consumer_secret     => "<consumer-secret>",
  :access_token        => "<access-token>",
  :access_token_secret => "<access-token-secret>"
}

client = Twitter::REST::Client.new(config)
num_attempts = 0
begin
  num_attempts += 2
  date_limit = (Date.today - DAYS).to_time
  client.user_timeline(USERNAME, :count => '150').each do |t|
    client.destroy_status(t.id) if t.created_at < date_limit;
  end
rescue Twitter::Error::TooManyRequests => error
  if num_attempts <= ATTEMPTS
    sleep error.rate_limit.reset_in
    retry
  else
    raise
  end
end