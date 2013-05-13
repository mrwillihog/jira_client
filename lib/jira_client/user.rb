module JiraClient
  class User < JiraClient::Base
    attr_reader :display_name, :email_address, :name

    def active?
      @attrs[:active] == true
    end

  end
end