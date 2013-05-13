require "spec_helper"

describe JiraClient::API::Projects do

  describe "#find_projects" do

    before do
      stub_get("/project").to_return(:body => fixture("projects.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end

    it "requests the correct resource" do
      JiraClient.find_projects
      expect(a_get("/project")).to have_been_made
    end
    it "returns an array of JiraClient::Project objects" do
      projects = JiraClient.find_projects
      projects.should be_a_kind_of Array
      projects.each do |project|
        project.should be_a_kind_of JiraClient::Project
      end
    end
    it "assigns the correct information" do
      projects = JiraClient.find_projects
      projects.first.name.should == "Example"
      projects.first.key.should == "EX"
      projects.last.name.should == "Alphabetical"
      projects.last.key.should == "ABC"
    end
  end

  describe "#find_project_by_key" do

    before do
      stub_get("/project/ABC").to_return(:body => fixture("project.json"), :headers => {:content_type => "application/json; charset=utf-8"})
    end

    it "requests the correct resource" do
      JiraClient.find_project_by_key(:ABC)
      expect(a_get('/project/ABC')).to have_been_made
    end
    it "returns a JiraClient::Project object" do
      project = JiraClient.find_project_by_key :ABC
      project.should be_a_kind_of JiraClient::Project
    end
    it "accepts a key as a string" do
      project = JiraClient.find_project_by_key "ABC"
      project.should be_a_kind_of JiraClient::Project
    end
    it "accepts a key as a symbol" do
      project = JiraClient.find_project_by_key :ABC
      project.should be_a_kind_of JiraClient::Project
    end
  end

end