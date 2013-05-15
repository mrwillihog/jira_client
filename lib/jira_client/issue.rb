require "jira_client/status"
require "jira_client/timetracking"
require "jira_client/project"
require "jira_client/worklog"
require "jira_client/issue_type"

module JiraClient
  class Issue < JiraClient::Base
    attr_reader :key, :description, :summary, :status, :timetracking, :project, :worklog, :comment, :issuetype, :subtasks

    convert :status, JiraClient::Status
    convert :timetracking, JiraClient::Timetracking
    convert :comment, lambda {|response| response[:comments].map {|comment| JiraClient::Comment.from_response(comment) } }
    convert :project, JiraClient::Project
    convert :worklog, JiraClient::Worklog
    convert :issuetype, JiraClient::IssueType
    convert :subtasks, JiraClient::Issue

    class << self

      def from_response(params)
        # Make values nested in the :fields key top-level values
        params.merge!(params[:fields]).delete :fields if params.has_key? :fields
        super(params)
      end

    end

    alias :comments :comment
  end
end