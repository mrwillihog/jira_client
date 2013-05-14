module JiraClient
  class IssueType < JiraClient::Base
    attr_reader :description, :name, :subtask
  end
end