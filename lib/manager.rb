# frozen_string_literal: true

require 'yaml'
require 'logger'
require_relative 'twitter.rb'

# Common / Destroyer and Unfavoriter
class TweetsManager
  attr_reader :client

  TIMESTAMP_FORMAT = '%Y-%m-%dT%H:%M:%S.%06N'
  SECRETS_FILE_PATH = 'config/secrets.yml'

  def initialize(screen_name)
    token = load_token(screen_name)
    @client = Twitter::REST::Client.new(token)
    @screen_name = screen_name
    logger
  end

  private

  def logger
    @logger ||= Logger.new("log/#{self.class.name}_#{@screen_name}_#{timestamp}.log")
  end

  def load_token(screen_name)
    secrets_file = File.open(SECRETS_FILE_PATH)
    secrets = YAML.safe_load(secrets_file)

    secrets[screen_name]
  end

  def timestamp
    Time.now.strftime(TIMESTAMP_FORMAT)
  end

  def select_tweets_within_period(tweets, options = {})
    select_tweets_within_period_options = {
      since_time: options[:since_time],
      until_time: options[:until_time]
    }.compact

    tweets.select do |tweet|
      tweet.within_period?(**select_tweets_within_period_options)
    end
  end
end
