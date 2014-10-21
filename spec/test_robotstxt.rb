require 'spec_helper'

require 'open-uri'
require File.dirname(__FILE__) + '/../lib/robotstxtparser'

describe "RobotsTxtParser init" do
	it "should use file.open for files" do
		filename = File.dirname(__FILE__) + '/../test/data/robots1.txt'
		expect(File).to receive(:open).with(filename)
		p = RobotsTxtParser.new()
		p.read(filename)
	end

	it "should not fail with missing file" do
		p = RobotsTxtParser.new()
		p.read("omg")
	end

	it "should use Uri.open for urls" do
		address = "http://google.com/"
		expect(OpenURI).to receive(:open_uri).with(URI.parse(address))
		p = RobotsTxtParser.new()
		p.read(address)
	end
end

describe "RobotsTxtParser" do
	before do
		path = File.dirname(__FILE__) + '/../test/data/robots1.txt'
		@p = RobotsTxtParser.new()
		@p.read(path)
	end

	it "should parse user agents" do
		expect(@p.user_agents).to include('Google')
		expect(@p.user_agents).to include('Yahoo')
		expect(@p.user_agents).to_not include('Autobot')
	end

	it "should parse disallows" do
		expect(@p.user_agent('*')).to include('/logs')
		expect(@p.user_agent('Google')).to include('/google-dir')
		expect(@p.user_agent('Yahoo')).to include('/yahoo-dir')

		expect(@p.user_agent('Autobot')).to include('/logs')
		expect(@p.user_agent('Autobot')).to_not include('/google-dir')
	end

	it "should include wildcard disallows" do
		expect(@p.user_agent('Yahoo')).to include('/logs')
		expect(@p.user_agent('Google')).to include('/logs')
	end

	it "should found sitemap" do
		expect(@p.sitemaps).to include('http://something.com/sitemap.xml')
	end
end