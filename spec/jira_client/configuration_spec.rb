require "spec_helper"

describe "JiraClient.reset!" do
  it "resets all options to defaults" do
    JiraClient.configure do |config|
      config.base_url = "some_url"
      config.port = 2411
      config.username = "admin"
      config.password = "password"
    end
    JiraClient.reset!
    expect(JiraClient.configuration).to be_nil
  end
end

describe "JiraClient.configure" do
  it "config variables are accessible through the configuration method" do
    JiraClient.configure do |config|
      config.base_url = "https://example.jira.com"
    end
    expect(JiraClient.configuration.base_url).to eq("https://example.jira.com")
  end
  it "raises JiraClient::Error::ConfigurationError when an unknown config option is provided" do
    expect do
      JiraClient.configure do |config|
        config.unknown_config_variable = "not allowed"
      end
    end.to raise_error(JiraClient::Error::ConfigurationError)
  end

  describe "authentication options" do
    describe "basic authentication" do
      it "accepts a username" do
        expect do
          JiraClient.configure {|c| c.username = "admin"}
        end.not_to raise_error
      end
      it "accepts a password" do
        expect do
          JiraClient.configure {|c| c.password = "admin"}
        end.not_to raise_error
      end
    end
  end
end

describe "JiraClient.configuration" do
  it "raises an error when #configure has not been run" do
    JiraClient.stub(:configuration).and_return(nil)
    expect { JiraClient.find_issue_by_key "TEST-1" }.to raise_error(JiraClient::Error::ConfigurationError)
  end

  describe "#full_url" do
    it "includes the base_url" do
      JiraClient.configure {|c| c.base_url = "http://localhost"}
      JiraClient.configuration.full_url.should include("http://localhost")
    end
    it "includes the port if specified" do
      JiraClient.configure do |config|
        config.base_url = "http://localhost"
        config.port = 2990
      end
      JiraClient.configuration.full_url.should include(":2990")
    end
    it "includes the default API path" do
      JiraClient.configure {|c| c.base_url = "http://localhost"}
      JiraClient.configuration.full_url.should include ("/rest/api/2")
    end
    it "trims trailing / from the base_url" do
      JiraClient.configure {|c| c.base_url = "http://localhost/"}
      JiraClient.configuration.full_url.should == "http://localhost/rest/api/2"
    end
    it "raises an error if not configured properly" do
      JiraClient.configure {|c| c.base_url = nil}
      expect { JiraClient.configuration.full_url }.to raise_error JiraClient::Error::ConfigurationError
    end
  end
end