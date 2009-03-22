require File.join(File.dirname(__FILE__), '..', 'lib', 'jointfeed')
require 'ostruct'
require 'spec'
require 'elementor'
require 'elementor/spec'

describe 'a JointFeed' do
  include Elementor

  before :each do
    @feed_urls = ["http://feed1.test/posts.xml", "http://feed2.test/posts.xml"]
    base_date  = Time.parse("1/1/2009") 
    @feeds = [mock("Feed", :title => "TITLE1", 
                           :entries => [OpenStruct.new({:summary   => "SUMMARY1",
                                                        :published => base_date}),
                                        OpenStruct.new({:summary   => "SUMMARY2",
                                                        :published => base_date + 10})]),
              mock("Feed", :title => "TITLE2",
                           :entries => [OpenStruct.new({:summary   => "SUMMARY2",
                                                        :published => base_date + 10}),
                                        OpenStruct.new({:summary   => "SUMMARY3",
                                                        :published => base_date + 5})])]
    @feed_urls.each_with_index do |url, index|
      Feedzirra::Feed.should_receive(:fetch_and_parse).with(url).and_return(@feeds[index])
    end
    @it = JointFeed.new(@feed_urls)
  end

  it "should have a collection of entries" do
    @it.entries.class.should == Array
  end

  it "should return a collection the size of unique entries" do
    @it.entries.size.should == 3
  end

  it "should only have one of the duplicate entries" do
    @it.entries.select { |entry| entry.summary == "SUMMARY2" }.size.should == 1
  end 

  it "should have a title that includes both feed titles" do
    @it.title.should match(/#{@feeds[0].title}/)
    @it.title.should match(/#{@feeds[1].title}/)
  end

  it "should sort the combined array of entries by date" do
    @it.entries.should == @it.entries.sort {|a,b| a.published <=> b.published }
  end
end
