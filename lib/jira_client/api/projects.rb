require "jira_client/api/utils"
require "jira_client/project"

module JiraClient
  module API
    module Projects
      include JiraClient::API::Utils

      def find_projects
        objects_from_response(JiraClient::Project, :get, '/project')
      end

      def find_project_by_key(key)
        object_from_response(JiraClient::Project, :get, "/project/#{key.to_s}")
      end

    end
  end
end