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

      def current_user
        request = resource(JiraClient.configuration.base_url)
        response = request["/rest/gadget/1.0/currentUser"].get
        JiraClient::User.from_response snake_case!(JSON.parse(response, :symbolize_names => true))
      end

    end
  end
end
