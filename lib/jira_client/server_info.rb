require "time"
require "jira_client/base"

module JiraClient
  class ServerInfo < JiraClient::Base
    attr_reader :version, :base_url, :build_number, :build_date, :server_title, :server_time

    convert :server_time, lambda {|value| Time.parse(value)}
    convert :build_date, lambda {|value| Time.parse(value)}

    def to_s
      "#{base_url} (#{version})"
    end
  end
end