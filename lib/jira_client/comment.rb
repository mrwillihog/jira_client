require "jira_client/user"

module JiraClient
  class Comment < JiraClient::Base
    attr_reader :id, :author, :body, :update_author, :created, :updated

    convert :author, JiraClient::User
    convert :update_author, JiraClient::User
    convert :created, lambda {|value| DateTime.parse(value)}
    convert :updated, lambda {|value| DateTime.parse(value)}
  end
end