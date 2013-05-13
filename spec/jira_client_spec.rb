require "spec_helper"

describe JiraClient do
  describe "proxy server" do
    it "sets the proxy server on RestClient" do
      JiraClient.configure do |config|
        config.proxy = "http://myproxy.com"
      end
      # Build the resource
      JiraClient.send(:resource)
      RestClient.proxy.should == "http://myproxy.com"
    end
  end
  describe "basic authentication" do

    before do
      @basic_auth_url = JiraClient.configuration.full_url.gsub("https://", "https://admin:admin@") + "/project"
      stub_request(:get, @basic_auth_url).to_return(:body => fixture("projects.json"))
    end

    it "sends a username/password when provided" do
      JiraClient.configure {|c| c.username = "admin"; c.password = "admin"}
      JiraClient.find_projects
      expect(a_request(:get, @basic_auth_url)).to have_been_made
    end
  end

  describe "certificate authentication" do

    before do
      JiraClient.configure do |config|
        config.certificate = fixture("my_certificate.pem")
        config.certificate_passphrase = "password"
      end
      @resource_options = JiraClient.send(:resource).options
    end

    it "sets ssl_client_cert" do
      @resource_options[:ssl_client_cert].should_not be_nil
    end
    it "sets ssl_client_key" do
      @resource_options[:ssl_client_key].should_not be_nil
    end
    it "sets verify_ssl" do
      @resource_options[:verify_ssl].should_not be_nil
      @resource_options[:verify_ssl].should == OpenSSL::SSL::VERIFY_NONE
    end
  end
end