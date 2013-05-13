require "simplecov"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start

require "webmock/rspec"
require "jira_client"

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.before(:each) do
    JiraClient.configure do |c|
      c.base_url = "https://example.jira.com"
    end
  end
  config.after(:each) do
    JiraClient.reset!
  end
end

def a_get(path)
  a_request(:get, JiraClient.configuration.full_url + path)
end

def a_post(path)
  a_request(:post, JiraClient.configuration.full_url + path)
end

def a_put(path)
  a_request(:put, JiraClient.configuration.full_url + path)
end

def stub_get(path)
  stub_request(:get, JiraClient.configuration.full_url + path)
end

def stub_post(path)
  stub_request(:post, JiraClient.configuration.full_url + path)
end

def stub_put(path)
  stub_request(:put, JiraClient.configuration.full_url + path)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end