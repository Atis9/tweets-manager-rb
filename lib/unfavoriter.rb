# frozen_string_literal: true

require_relative 'manager.rb'

# Twitter::REST::Favorites#unfavorite
class TweetsUnfavoriter < TweetsManager
  def initialize(screen_name:)
    super(screen_name: screen_name)
  end

  def run(options = {})
    all_favorites = get_all_favorites(@screen_name)
    tweets = select_tweets_within_period(all_favorites, options)
    return if tweets.empty?

    tweets.each do |tweet|
      unfavorite(tweet)
    end

    run(options)
  end

  private

  def unfavorite(tweet)
    @client.unfavorite(tweet)

    logger.info(%(Unfavorite: { id: #{tweet.id}, text: "#{tweet.full_text.gsub(/\n/, '\\n')}" }))
  rescue StandardError => e
    logger.warn("#{e.class}: #{e.message}")
  end

  def get_all_favorites(screen_name)
    options = { count: 200 }

    @client.favorites(screen_name, options)
  rescue Twitter::Error::TooManyRequests => e
    logger.warn("#{e.class}: #{e.message}")

    []
  end
end
