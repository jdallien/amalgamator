require File.join(File.dirname(__FILE__), '..', 'lib', 'jointfeed')
require File.join(File.dirname(__FILE__), '..', 'amalgamator')
require 'rack/test'

set :environment, :test

describe 'The main page' do
  include Rack::Test::Methods

  before :each do
    get '/'
    @html = Nokogiri::HTML(last_response.body)
  end

  def app
    Sinatra::Application
  end

  it "has text boxes for the feed URLs" do
     # tag.feed_url_inputs 'input.feed_url'
    @html.css("input.feed_url").size.should == 2
  end

  it "has a submit button" do
     # tag.submit_button 'input.submit'
    @html.css("input.submit").size.should == 1
  end
end

describe 'getting two joined feeds' do
  include Rack::Test::Methods

  before :each do
    @jointfeed = mock(JointFeed,
      :title       => "TITLE",
      :entries     => (1..3).map{ mock_entry },
      :description => "DESCRIPTION")
    JointFeed.should_receive(:new).and_return(@jointfeed)

    get "/feed", 'feeds' =>
      ["http://feed1.test/posts.xml",
       "http://feed2.test/posts.xml"]
    @xml = Nokogiri::XML(last_response.body)
  end

  def app
    Sinatra::Application
  end

  def mock_entry
    mock("Entry", :title     => "TITLE",
                  :summary   => "SUMMARY",
                  :published => "DATE",
                  :id        => "GUID",
                  :url       => "LINK")
  end

  it "should respond ok" do
    last_response.should be_ok
  end

  it "should return an RSS XML document" do
    last_response.content_type.should == "application/rss+xml"
  end

  it "should have the correct number of feed items" do
    @xml.xpath("//rss/channel/item").size.should ==
      @jointfeed.entries.size
  end

  it "should repeat the items' guid field in the combined feed" do
    guid_tags = @xml.xpath("//rss/channel/item/guid")
    guid_tags.size.should == 3
    guid_tags.first.inner_text.should == "GUID"
  end

  it "should repeat the items' link field in the combined feed" do
    link_tags = @xml.xpath("//rss/channel/item/link")
    link_tags.size.should == 3
    link_tags.first.inner_text.should == "LINK"
  end
end
