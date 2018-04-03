require 'bundler'
require 'json'
require 'net/https'
require 'kconv'

Bundler.require
require 'twitter'
require 'clockwork'

module Clockwork
  ACCOUNT_NAME = ['hinabitter', 'coconatsu5572']

  configure do |config|
    logger = Logger.new('hinabita.log')
    logger.level = Logger::WARN
    config[:logger] = logger
  end

  @facebook_graph = Koala::Facebook::API.new(ENV['FB_ACCESS_TOKEN'])
  @twitter_client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV['TW_CONSUMER_KEY']
    config.consumer_secret = ENV['TW_CONSUKMER_SECRET']
    config.access_token = ENV['TW_ACCESS_TOKEN']
    config.access_token_secret = ENV['TW_ACCESS_TOKEN_SECRET']
  end

  handler do |account_name|
    feeds_time = @facebook_graph.get_connections("#{account_name}", 'feed').first['created_time'].to_time
    if @latest[account_name] < feeds_time
      @twitter_client.update("Facebook更新めう！ [https://www.facebook.com/#{account_name}]　[#{time.strftime("%m-%d %H:%M")}]".toutf8)
      @latest[account_name] = feeds_time
    end
  end

  ACCOUNT_NAME.each do |job|
    @latest[job] = @facebook_graph.get_connections(job, 'feed').first['created_time'].to_time
    every(1.seconds, job)
  end
end
