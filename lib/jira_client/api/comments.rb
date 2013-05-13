require "jira_client/api/utils"

module JiraClient
  module API
    module Comments
      include JiraClient::API::Utils

      def find_issue_comments(key)
        response = get("/issue/#{key}/comment")
        response[:comments].map {|c| JiraClient::Comment.from_response c}
      end

      def comment_on_issue(key, message)
        object_from_response(JiraClient::Comment, :post, "/issue/#{key}/comment", {:body => message})
      end

    end
  end
end