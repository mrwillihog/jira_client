module JiraClient
  class Status < JiraClient::Base
    OPEN = 1; CLOSE = 2; START_PROGRESS = 4; REOPEN = 3; RESOLVE = 5;

    attr_reader :id, :name, :description
  end
end