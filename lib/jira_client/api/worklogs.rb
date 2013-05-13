require "chronic_duration"

module JiraClient
  module API
    module Worklogs

      def create_worklog(key, time, opts={})
        url = "/issue/#{key}/worklog"
        url += "?adjustEstimate=new&newEstimate=#{opts[:remaining_estimate]}" if opts.has_key? :remaining_estimate
        url += "?adjustEstimate=manual&reduceBy=#{opts[:reduce_estimate]}" if opts.has_key? :reduce_estimate
        time_in_seconds = ChronicDuration.parse(time)
        params = {
          :timeSpentSeconds => time_in_seconds
        }
        params[:comment] = opts[:comment] if opts.has_key? :comment
        post(url, params)
      end

      def find_issue_worklogs(key)
        response = get("/issue/#{key}/worklog")
        response[:worklogs].map {|w| JiraClient::Worklog.from_response w}
      end

    end
  end
end