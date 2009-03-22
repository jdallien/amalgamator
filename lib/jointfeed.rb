require 'feedzirra'

class JointFeed
  class FeedError < StandardError; end

  def initialize(feeds)
    raise ArgumentError, "Need two feeds to join." unless feeds.size == 2
    load_feeds(feeds)
  end

  def entries
    feed_without_duplicates = @feeds[0].entries.reject do |entry|
      @feeds[1].entries.any? {|other| entry.summary == other.summary}
    end
    feed_without_duplicates + @feeds[1].entries
  end

  def title
    @feeds.map(&:title).join(' + ')
  end

  def description
    "A joined feed"
  end

  private

  def load_feeds(feed_urls)
    @feeds = []
    feed_urls.each do |feed_url|
      feed = Feedzirra::Feed.fetch_and_parse(feed_url)
      if feed.is_a?(Fixnum)
        raise FeedError, "Error: Could not get RSS feed: #{feed_url}, got #{feed} error"
      else  
        @feeds << feed
      end
    end
  end
end
