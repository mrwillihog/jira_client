require "jira_client/api/utils"

module JiraClient
  module API
    module Users
      include JiraClient::API::Utils

      def find_users(username)
        objects_from_response(JiraClient::User, :get, "/user/search", :username => username)
      end

      def find_user_by_username(username)
        object_from_response(JiraClient::User, :get, "/user", :username => username)
      end

    end
  end
end