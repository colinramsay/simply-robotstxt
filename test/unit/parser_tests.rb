require 'open-uri'
require File.dirname(__FILE__) + '/../../lib/robotstxtparser'

describe "RobotsTxtParser init" do
  it "should use file.open for files" do
    filename = File.dirname(__FILE__) + '/../data/robots1.txt'
    File.should_receive(:open).with(filename)
    RobotsTxtParser.new(filename)
  end

  it "should use Uri.open for urls" do
    address = "http://google.com/"
    OpenURI.should_receive(:open_uri).with(URI.parse(address))
    RobotsTxtParser.new(address)
  end
end

describe "RobotsTxtParser" do
  before do
    path = File.dirname(__FILE__) + '/../data/robots1.txt'
    @p = RobotsTxtParser.new(path)
  end

  it "should parse user agents" do
    @p.user_agents.should include('Google')
    @p.user_agents.should include('Yahoo')
  end

  it "should parse disallows" do
    @p.user_agents['*'].should include('/logs')
    @p.user_agents['Google'].should include('/google-dir')
    @p.user_agents['Yahoo'].should include('/yahoo-dir')
  end

  it "should include wildcard disallows" do
    @p.user_agents['Yahoo'].should include('/logs')
    @p.user_agents['Google'].should include('/logs')
  end
end
