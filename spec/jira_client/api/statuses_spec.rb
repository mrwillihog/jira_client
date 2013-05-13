require "spec_helper"

describe JiraClient::API::Statuses do

  describe "#find_statuses" do

    before do
      stub_get("/status").to_return(:body => fixture("statuses.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end

    it "requests the correct resource" do
      JiraClient.find_statuses
      expect(a_get('/status')).to have_been_made
    end
    it "returns an array of JiraClient::Status objects" do
      statuses = JiraClient.find_statuses
      statuses.should be_a_kind_of Array
      statuses.each do |status|
        status.should be_a_kind_of JiraClient::Status
      end
    end
    it "assigns the correct information" do
      statuses = JiraClient.find_statuses
      statuses.first.name.should == "In Progress"
      statuses.first.description.should == "The issue is currently being worked on."
      statuses.last.name.should == "Closed"
      statuses.last.description.should == "The issue is closed."
    end
  end

  describe "#find_status_by_id" do

    before do
      stub_get("/status/10000").to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      @status = JiraClient.find_status_by_id 10000
    end

    it "requests the correct resource" do
      expect(a_get("/status/10000")).to have_been_made
    end
    it "returns a JiraClient::Status object" do
      @status.should be_a_kind_of JiraClient::Status
    end
    it "assigns the correct information" do
      @status.name.should == "In Progress"
      @status.id.should == "10000"
    end
  end

  describe "#find_status_by_name" do

    before do
      stub_get("/status/In%20Progress").to_return(:body => fixture("status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      @status = JiraClient.find_status_by_name "In Progress"
    end

    it "requests the correct resource" do
      expect(a_get("/status/In Progress")).to have_been_made
    end
    it "returns a JiraClient::Status object" do
      @status.should be_a_kind_of JiraClient::Status
    end
    it "assigns the correct information" do
      @status.name.should == "In Progress"
      @status.id.should == "10000"
    end
  end

end