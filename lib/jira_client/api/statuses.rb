require 'jira_client/api/utils'
require "jira_client/status"

module JiraClient
  module API
    module Statuses
      include JiraClient::API::Utils

      def find_statuses
        objects_from_response(JiraClient::Status, :get, '/status')
      end

      def find_status_by_id(id)
        object_from_response(JiraClient::Status, :get, "/status/#{id}")
      end
      alias :find_status_by_name :find_status_by_id

    end
  end
end