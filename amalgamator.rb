require 'rubygems'
require 'sinatra'
require 'builder'
require 'feedzirra'
require File.join(File.dirname(__FILE__), 'lib', 'jointfeed')

get '/' do
  @feed_urls = []
  erb :index
end

get '/feed' do
  begin
    @feed_urls = params['feeds'] || []
    @feed = JointFeed.new(@feed_urls)
    content_type 'application/rss+xml'
    builder :feed
  rescue ArgumentError, JointFeed::FeedError => e
    @error = e.message
    erb :index
  end
end
