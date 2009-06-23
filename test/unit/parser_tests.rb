require 'fake_web'
require 'open-uri'
require 'delegate'

class SymbolKeyHash < DelegateClass(Hash)
  def initialize
    super({})
  end

  #def []=(k,v)
   # __getobj__[(k.downcase rescue k)] = v 
  #end 
end

class RobotsTxtParser

  attr_reader :user_agents

  def initialize(path)
    if path.include?("://")
      raw_data = open(path)
    else
      raw_data = File.open(path)
    end

    return unless raw_data

    @user_agents = SymbolKeyHash.new

    parse(raw_data)

  end

  def parse(raw_data)
    current_agent = nil

    raw_data.each_line do |line|

      if line.match(/^User Agent:/)
        current_agent = line.gsub("User Agent:","").strip
      elsif line.match(/^Disallow:/)
	@user_agents[current_agent] = Array.new unless @user_agents[current_agent]
        @user_agents[current_agent].push line.gsub("Disallow:", "").strip
      end
    end    
  end
end

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
    @p.user_agents['Google'].should include('/google-dir')
    @p.user_agents['Yahoo'].should include('/yahoo-dir')
  end

  it "should include wildcard disallows" do
    pending("implement wildcard inclusion")
  end
end
