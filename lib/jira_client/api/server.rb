require "jira_client/api/utils"
require "jira_client/server_info"

module JiraClient
  module API
    module Server
      include JiraClient::API::Utils

      def server_info
        object_from_response(JiraClient::ServerInfo, :get, "/serverInfo")
      end

    end
  end
end