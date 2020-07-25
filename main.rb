# frozen_string_literal: true

require_relative 'lib/destroyer.rb'
require_relative 'lib/unfavoriter.rb'

two_days_ago = Time.now - (60 * 60 * 24 * 2)

destroyer_atis = TweetsDestroyer.new(screen_name: 'AtiS')
destroyer_atis.run(until_time: two_days_ago)

# unfavoriter_atis = TweetsUnfavoriter.new(screen_name: 'AtiS')
# unfavoriter_atis.run(until_time: two_days_ago)
