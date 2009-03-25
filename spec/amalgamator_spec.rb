require File.join(File.dirname(__FILE__), '..', 'lib', 'jointfeed')
require File.join(File.dirname(__FILE__), '..', 'amalgamator')
require 'spec'
require 'spec/interop/test'
require 'sinatra/test'
require 'elementor'
require 'elementor/spec'

set :environment, :test

describe 'The main page' do
  include Sinatra::Test
  include Elementor

  before :each do
    @page = elements(:from => :do_get) do |tag|
      tag.feed_url_inputs 'input.feed_url'
      tag.submit_button 'input.submit'
    end
  end

  def do_get
    get '/'
    response.body
  end

  it "has text boxes for the feed URLs" do
    @page.should have(2).feed_url_inputs
  end

  it "has a submit button" do
    @page.should have(1).submit_button
  end
end

describe 'getting two joined feeds' do
  include Sinatra::Test
  include Elementor

  before :each do
    @jointfeed = mock(JointFeed, :title       => "TITLE",
                                 :entries     => 3.times.map{ mock_entry },
                                 :description => "DESCRIPTION")
    JointFeed.should_receive(:new).and_return(@jointfeed)
    @page = elements(:from => :do_get, :as => :xml) do |tag|
      tag.items 'item'
      tag.guids 'guid'
      tag.links 'item/link'
    end
  end

  def mock_entry
    mock("Entry", :title     => "TITLE",
                  :summary   => "SUMMARY",
                  :published => "DATE",
                  :id        => "GUID",
                  :url       => "LINK")
  end

  def do_get
    get "/feed", 'feeds' => ["http://feed1.test/posts.xml", "http://feed2.test/posts.xml"]
    response.body
  end

  it "should respond ok" do
    do_get
    response.should be_ok
  end

  it "should return an RSS XML document" do
    do_get
    response.content_type.should == "application/rss+xml"
  end

  it "should have the correct number of feed items" do
    @page.should have(@jointfeed.entries.size).items
  end

  it "should repeat the items' guid field in the combined feed" do
    @page.guids.size.should == 3
    @page.guids[0].inner_text.should == "GUID"
  end

  it "should repeat the items' link field in the combined feed" do
    @page.links.size.should == 3
    @page.links[0].inner_text.should == "LINK"
  end
end
