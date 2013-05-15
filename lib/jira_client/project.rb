module JiraClient
  class Project < JiraClient::Base
    attr_reader :name, :key

    def to_s
      name
    end
  end
end