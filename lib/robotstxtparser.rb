require 'open-uri'

class RobotsTxtParser
  @@user_agents
  attr_accessor :sitemaps

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

    @@user_agents = Hash.new
    @sitemaps = Array.new

    return if raw_data == nil

    parse(raw_data)
  end

  def parse(raw_data)
    current_agent = nil

    raw_data.each_line do |line|
      if line.match(/^user agent:/i) || line.match(/^user-agent:/i)
        current_agent = line[line.index(":") + 1, line.length].strip
      elsif line.match(/^disallow:/i)
        @@user_agents[current_agent] = Array.new if @@user_agents[current_agent] == nil
        @@user_agents[current_agent].push line.gsub(/^disallow:/i, "").strip
      elsif line.match(/^sitemap:/i)
        @sitemaps.push line.gsub(/^sitemap:/i, "").strip
      end
    end

    add_wildcard_records 
  end

  def add_wildcard_records
    if @@user_agents.has_key?('*')
      @@user_agents.each do |agent, records|
        @@user_agents[agent] = records + @@user_agents['*']
      end
    end
  end

  def user_agents(agent)
    unless @@user_agents[agent] == nil
      return @@user_agents[agent]
    else
      return @@user_agents["*"]
    end
  end
end