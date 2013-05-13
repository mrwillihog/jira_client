require "jira_client/api/utils"

module JiraClient
  module API
    module Issues
      include JiraClient::API::Utils

      def find_issues(params={})
        response = post("/search", params)
        response[:issues].map {|i| JiraClient::Issue.from_response i}
      end

      def find_issue_by_key(key, params={})
        fields = params[:fields].join "," if params.has_key? :fields
        url = "/issue/#{key}"
        url << "?fields=#{fields}" if fields
        object_from_response(JiraClient::Issue, :get, url)
      end

      def assign_issue(key, username)
        put("/issue/#{key}/assignee", :name => username)
      end

      def close_issue(key, params={})
        transition_to(key, JiraClient::Status::CLOSE, params)
      end

      def reopen_issue(key, params={})
        transition_to(key, JiraClient::Status::REOPEN, params)
      end

      def resolve_issue(key, params={})
        transition_to(key, JiraClient::Status::RESOLVE, params)
      end

      def start_progress_on_issue(key, params={})
        transition_to(key, JiraClient::Status::START_PROGRESS, params)
      end

    private

      def transition_to(key, transition, params={})
        opts = {:transition => {:id => transition}}
        if params.has_key? :as
          opts[:fields] ||= {}
          opts[:fields][:resolution] = {:name => params[:as]}
        end
        opts[:update] = comment_hash(params[:comment])

        # Remove keys with nil values
        opts.reject! {|k,v| v.nil?}
        post("/issue/#{key}/transitions", opts)
      end

      def comment_hash(comment)
        return unless comment
        {:comment => [{:add => {:body => comment}}]}
      end

    end
  end
end