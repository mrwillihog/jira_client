require "rest-client"
require "json"

require "jira_client/base"
require "jira_client/comment"
require "jira_client/configuration"
require "jira_client/issue"
require "jira_client/project"
require "jira_client/status"
require "jira_client/timetracking"
require "jira_client/user"
require "jira_client/worklog"
require "jira_client/api/comments"
require "jira_client/api/issues"
require "jira_client/api/projects"
require "jira_client/api/server"
require "jira_client/api/statuses"
require "jira_client/api/users"
require "jira_client/api/worklogs"
require "jira_client/core_ext/string"
require "jira_client/error/configuration_error"
require "jira_client/error/bad_request"
require "jira_client/error/issue_error"
require "jira_client/error/resource_not_found"
require "jira_client/error/unauthorized"

module JiraClient
  class << self
    include JiraClient::API::Comments
    include JiraClient::API::Issues
    include JiraClient::API::Projects
    include JiraClient::API::Server
    include JiraClient::API::Statuses
    include JiraClient::API::Users
    include JiraClient::API::Worklogs

    attr_accessor :configuration
    def configure
      self.configuration ||= Configuration.new
      begin
        yield(configuration)
      rescue NoMethodError => e
        raise JiraClient::Error::ConfigurationError, "Unrecognized configuration option provided #{e.message}"
      end
    end

    def reset!
      self.configuration = nil
      @resource = nil
    end

  private

    def get(path, params={})
      request(:get, path, :params => params)
    end

    def post(path, params={})
      request(:post, path, params.to_json)
    end

    def put(path, params={})
      request(:put, path, params.to_json)
    end

    def request(method, path, params={})
      begin
        response = resource[URI.encode(path)].send(method.to_sym, params)
        snake_case!(JSON.parse(response, :symbolize_names => true)) unless response.empty?
      rescue RestClient::ResourceNotFound => e
        raise_error JiraClient::Error::ResourceNotFound, e
      rescue RestClient::BadRequest => e
        raise_error JiraClient::Error::BadRequest, e
      rescue RestClient::Unauthorized => e
        raise_error JiraClient::Error::Unauthorized, e
      end
    end

    def raise_error(error_type, message_response)
      raise error_type, JSON.parse(message_response.response)["errorMessages"].join
    end

    # Returns a RestClient resource
    def resource(url=nil)
      raise JiraClient::Error::ConfigurationError, "No configuration found. Please run JiraClient.configure" if JiraClient.configuration.nil?
      @resource ||= begin
        url = url || JiraClient.configuration.full_url
        options = {
          :headers => {:content_type => :json, :accept => :json}
        }

        RestClient.proxy = JiraClient.configuration.proxy

        unless JiraClient.configuration.certificate.nil?
          options[:ssl_client_cert] = OpenSSL::X509::Certificate.new File.read(JiraClient.configuration.certificate)
          options[:ssl_client_key] = OpenSSL::PKey::RSA.new File.read(JiraClient.configuration.certificate), JiraClient.configuration.certificate_passphrase
          options[:verify_ssl] = OpenSSL::SSL::VERIFY_NONE
        else
          # RestClient will ignore basic auth parameters if nil
          options[:user] = JiraClient.configuration.username
          options[:password] = JiraClient.configuration.password
        end

        RestClient::Resource.new(url, options)
      end
    end

    # Convert CamelCaseKeys to snake_case_keys
    def snake_case!(value)
      case value
        when Array
          value.map {|v| snake_case!(v)}
        when Hash
          Hash[value.map {|k, v| [k.to_s.underscore.to_sym, snake_case!(v)] }]
        else
          value
      end
    end

  end
end
