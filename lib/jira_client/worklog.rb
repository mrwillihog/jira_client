module JiraClient
  class Worklog < JiraClient::Base
    attr_reader :time_spent, :comment, :author, :update_author, :started, :time_spent_seconds

    convert :author, JiraClient::User
    convert :update_author, JiraClient::User
    convert :started, lambda {|value| Time.parse(value)}
    convert :time_spent_seconds, lambda {|value| value.to_i }
  end
end