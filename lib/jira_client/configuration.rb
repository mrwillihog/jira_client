module JiraClient
  class Configuration
    attr_accessor :base_url, :api_path, :port, :proxy, :username, :password, :certificate, :certificate_passphrase

    def initialize
      @base_url = nil
      @port = nil
      @proxy = nil
      @api_path = "/rest/api/2"
      @username = nil
      @password = nil
      @certificate = nil
      @certificate_passphrase = nil
    end

    def full_url
      if @base_url.nil? or @api_path.nil?
        raise JiraClient::Error::ConfigurationError, "Invalid configuration. Run JiraClient.configure."
      end
      result = @base_url.gsub(/\/\z/, '')
      result += ":#{@port}" unless @port.nil?
      result += @api_path
      result
    end

  end
end