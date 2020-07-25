# frozen_string_literal: true

require 'twitter'

module Twitter
  # Add Twitter::Tweet#within_period?
  # Determine if tweets have been tweeted within a specified period
  class Tweet
    def within_period?(since_time: nil, until_time: nil)
      (!since_time || created_at >= since_time) &&
        (!until_time || created_at <= until_time)
    end
  end
end
