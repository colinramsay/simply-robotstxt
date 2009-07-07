require 'open-uri'

class RobotsTxtParser

  attr_reader :user_agents

  def read(path)
    begin
      if path.include?("://")
        raw_data = open(path)
      else
          raw_data = File.open(path)
      end
    rescue
      raw_data = nil
    end

    @user_agents = Hash.new

    return unless raw_data

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

    add_wildcard_records 
  end

  def add_wildcard_records
    if @user_agents.has_key?('*')
      @user_agents.each do |agent, records|
        @user_agents[agent] = records + @user_agents['*']
      end
    end
  end
end
