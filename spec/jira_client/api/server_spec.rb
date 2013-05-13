require "spec_helper"

describe JiraClient::API::Server do

  before do
    stub_get("/serverInfo").to_return(:body => fixture("server_info.json"), :headers => {:content_type => "application/json; charset=utf-8"})
  end

  describe "#info" do

    before do
      @info = JiraClient.server_info
    end

    it "requests the correct resource" do
      expect(a_get("/serverInfo")).to have_been_made
    end
    it "returns a JiraClient::ServerInfo object" do
      expect(@info).to be_a_kind_of JiraClient::ServerInfo
    end
    it "sets the correct attributes" do
      expect(@info.version).to eq("5.1.8")
      expect(@info.base_url).to eq("https://example.jira.com")
      expect(@info.build_number).to eq(787)
      expect(@info.build_date).to eq(Time.parse("2012-10-29T00:00:00.000+0000"))
      expect(@info.server_time).to eq(Time.parse("2013-04-24T22:01:45.802+0100"))
      expect(@info.server_title).to eq("Example JIRA")
    end
  end

end