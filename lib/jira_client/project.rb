module JiraClient
  class Project < JiraClient::Base
    attr_reader :name, :key
  end
end