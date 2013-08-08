module JiraClient
  class User < JiraClient::Base
    attr_reader :display_name, :email_address, :name, :username

    def active?
      @attrs[:active] == true
    end

    def to_s
      display_name
    end

  end
end
