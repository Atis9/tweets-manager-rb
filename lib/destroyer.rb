# frozen_string_literal: true

require_relative 'manager.rb'

# Twitter::REST::Tweets#destroy_status
class TweetsDestroyer < TweetsManager
  THREAD_SIZE = 16

  def initialize(screen_name:)
    super(screen_name: screen_name)
  end

  def run(options = {})
    all_tweets = get_all_tweets(@screen_name, options)
    tweets = select_tweets_within_period(all_tweets, options)
    threads = create_threads(tweets)

    threads&.each(&:join)
  end

  private

  def create_threads(tweets)
    tweets_groups = slice_tweets(tweets)
    return unless tweets_groups

    threads = []
    tweets_groups.each do |group|
      threads << Thread.new do
        destroy_all_status(group)
      end
    end

    threads
  end

  def slice_tweets(tweets)
    tweets_per_thread = (tweets.size.to_f / THREAD_SIZE).ceil
    return if tweets_per_thread < 1

    tweets.each_slice(tweets_per_thread).to_a
  end

  def destroy_status(tweet)
    @client.destroy_status(tweet.id)
    logger.info(%(Destroy: { id: #{tweet.id}, text: "#{tweet.full_text.gsub(/\n/, '\\n')}" }))
  rescue Twitter::Error::TooManyRequests => e
    sleep(e.rate_limit.reset_in + 1)
    retry
  rescue StandardError => e
    logger.warn("#{e.class}: #{e.message} #{tweet.id}")
  end

  def destroy_all_status(tweets)
    tweets.each { |t| destroy_status(t) }
  end

  # ref: twitter/AllTweets.md at master · sferik/twitter https://github.com/sferik/twitter/blob/master/examples/AllTweets.md
  def collect_with_max_id(collection = [], max_id = nil, &block)
    response = yield(max_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end

  def get_all_tweets(user, options = {})
    get_all_tweets_options = {
      include_rts: options[:include_rts],
      exclude_replies: options[:exclude_replies]
    }.compact

    collect_with_max_id do |max_id|
      timeline_options = { count: 200, include_rts: true }
      timeline_options[:max_id] = max_id unless max_id.nil?
      timeline_options.merge!(get_all_tweets_options)
      @client.user_timeline(user, timeline_options)
    end
  end
end
