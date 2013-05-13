module JiraClient
  class Timetracking < JiraClient::Base
    attr_reader :original_estimate, :remaining_estimate, :time_spent, :original_estimate_seconds,
                :remaining_estimate_seconds, :time_spent_seconds
  end
end