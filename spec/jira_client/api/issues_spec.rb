require "spec_helper"

describe JiraClient::API::Issues do

  describe "#find_issue_by_key" do
    context "with no extra data" do

      before do
        stub_get("/issue/PROJECT-1234").to_return(:body => fixture('basic_issue.json'), :headers => {:content_type => "application/json; charset=utf-8"})
      end

      it "requests the correct resource" do
        JiraClient.find_issue_by_key("PROJECT-1234")
        expect(a_get("/issue/PROJECT-1234")).to have_been_made
      end
      it "returns a JiraClient::Issue object" do
        issue = JiraClient.find_issue_by_key("PROJECT-1234")
        expect(issue).to be_a_kind_of JiraClient::Issue
      end
      it "sets the correct attributes" do
        issue = JiraClient.find_issue_by_key("PROJECT-1234")
        expect(issue.key).to eq("PROJECT-1234")
      end
    end
    context "with summary and description" do

      before do
        stub_get("/issue/PROJECT-1235").with(:query => {:fields => "summary,description"}).to_return(:body => fixture('issue_with_description.json'), :headers => {:content_type => "application/json; charset=utf-8"})
        @issue = JiraClient.find_issue_by_key("PROJECT-1235", :fields => [:summary, :description])
      end

      it "requests the correct resource" do
        expect(a_get("/issue/PROJECT-1235?fields=summary,description")).to have_been_made
      end
      it "sets the correct attributes" do
        expect(@issue.key).to eq("PROJECT-1235")
        expect(@issue.summary?).to be_true
        expect(@issue.description?).to be_true
        expect(@issue.summary).to eq("This is an issue summary")
        expect(@issue.description).to eq("This is a description")
      end
    end
    context "with a status" do

      before do
        stub_get("/issue/PROJECT-1236").with(:query => {:fields => "status"}).to_return(:body => fixture("issue_with_status.json"), :headers => {:content_type => "application/json; charset=utf-8"})
        @issue = JiraClient.find_issue_by_key("PROJECT-1236", :fields => [:status])
      end

      it "requests the correct resource" do
        expect(a_get("/issue/PROJECT-1236?fields=status")).to have_been_made
      end
      it "sets the correct attributes" do
        expect(@issue.key).to eq("PROJECT-1236")
        expect(@issue.status?).to be_true
        expect(@issue.status).to be_a_kind_of JiraClient::Status
      end
    end
    context "with an issuetype" do

      before do
        stub_get("/issue/PROJECT-1234").with(:query => {:fields => "issuetype"}).to_return(:body => fixture("issue_with_issuetype.json"))
        @issue = JiraClient.find_issue_by_key("PROJECT-1234", :fields => [:issuetype])
      end

      it "requests the correct resource" do
        expect(a_get("/issue/PROJECT-1234?fields=issuetype")).to have_been_made
      end
      it "sets the correct values" do
        type = @issue.issuetype
        expect(type).to be_a_kind_of JiraClient::IssueType
        type.name.should == "Bug"
        type.description.should == "A problem which impairs or prevents the functions of the product."
      end

    end
    context "with subtasks", focus: true do

      before do
        stub_get("/issue/PROJECT-1234").with(:query => {:fields => "subtasks"}).to_return(:body => fixture("issue_with_subtasks.json"))
        @issue = JiraClient.find_issue_by_key("PROJECT-1234", :fields => [:subtasks])
      end

      it "requests the correct resource" do
        expect(a_get("/issue/PROJECT-1234?fields=subtasks")).to have_been_made
      end
      it "sets the correct values" do
        subtasks = @issue.subtasks
        expect(subtasks).to be_a_kind_of Array
        subtasks.each do |subtask|
          expect(subtask).to be_a_kind_of JiraClient::Issue
          subtask.summary.should == "This is a subtask"
          subtask.issuetype.name.should == "Sub-task"
        end
      end

    end
    context "with timetracking" do

      before do
        stub_get("/issue/PROJECT-1234").with(:query => {:fields => "timetracking"}).to_return(:body => fixture("issue_with_timetracking.json"))
        @issue = JiraClient.find_issue_by_key("PROJECT-1234", :fields => [:timetracking])
      end

      it "requests the correct resource" do
        expect(a_get("/issue/PROJECT-1234?fields=timetracking")).to have_been_made
      end
      it "returns a timetracking object" do
        expect(@issue.timetracking).to be_a_kind_of JiraClient::Timetracking
      end
    end
    context "with worklogs" do

      before do
        stub_get("/issue/PROJECT-1234").with(:query => {:fields => "worklog"}).to_return(:body => fixture("issue_with_worklogs.json"))
        @issue = JiraClient.find_issue_by_key("PROJECT-1234", :fields => [:worklog])
      end

      it "requests the correct resource" do
        expect(a_get("/issue/PROJECT-1234?fields=worklog")).to have_been_made
      end
      it "returns an array of worklog items" do
        @issue.worklog.should be_a_kind_of Array
        @issue.worklog.each do |worklog|
          worklog.should be_a_kind_of JiraClient::Worklog
          worklog.author.should be_a_kind_of JiraClient::User
        end
      end
    end
    context "with comments" do

      before do
        stub_get("/issue/PROJECT-1234").with(:query => {:fields => "comment"}).to_return(:body => fixture("issue_with_comments.json"))
        @issue = JiraClient.find_issue_by_key("PROJECT-1234", :fields => [:comment])
      end

      it "requests the correct resource" do
        expect(a_get("/issue/PROJECT-1234?fields=comment")).to have_been_made
      end
      it "returns an array of comment objects" do
        @issue.comment.should be_a_kind_of Array
        @issue.comment.each do |comment|
          comment.should be_a_kind_of JiraClient::Comment
        end
      end
    end
  end

  describe "#assign_issue" do

    before do
      stub_put("/issue/PROJECT-1234/assignee").with(:body => {"name" => "testuser"}).to_return(:status => 204)
      JiraClient.assign_issue("PROJECT-1234", "testuser")
    end

    it "requests the correct resource" do
      expect(a_put("/issue/PROJECT-1234/assignee")).to have_been_made
    end
    context "with invalid username" do

      before do
        stub_put("/issue/PROJECT-1234/assignee").with(:body => {"name" => "invalid_user"}).to_return(:status => 400, :body => fixture("invalid_assignee.json"))
      end

      it "raises a JiraClient::Error::BadRequest error" do
        expect { JiraClient.assign_issue("PROJECT-1234", "invalid_user") }.to raise_error(JiraClient::Error::BadRequest)
      end
    end
    context "with invalid permissions" do

      before do
        stub_put("/issue/PROJECT-1234/assignee").with(:body => {"name" => "insufficient_permission_user"}).to_return(:status => 401, :body => fixture("invalid_assignee.json"))
      end

      it "raises JiraClient::Error::Unauthorized" do
        expect { JiraClient.assign_issue("PROJECT-1234", "insufficient_permission_user") }.to raise_error(JiraClient::Error::Unauthorized)
      end
    end
    context "with an issue that doesnt exist" do

      before do
        stub_put("/issue/NOEXIST/assignee").with(:body => {"name" => "admin"}).to_return(:status => 404, :body => fixture("invalid_assignee.json"))
      end

      it "raises JiraClient::Error::ResourceNotFound" do
        expect { JiraClient.assign_issue("NOEXIST", "admin") }.to raise_error(JiraClient::Error::ResourceNotFound)
      end
    end
    context "with a user that doesnt exist" do

      before do
        stub_put("/issue/PROJECT-1234/assignee").with(:body => {"name" => "no_exist_user"}).to_return(:status => 404, :body => fixture("invalid_assignee.json"))
      end

      it "raises JiraClient::Error::ResourceNotFound" do
        expect { JiraClient.assign_issue("PROJECT-1234", "no_exist_user") }.to raise_error(JiraClient::Error::ResourceNotFound)
      end
    end
  end

  describe "#resolve_issue" do

    before do
      stub_post("/issue/PROJECT-1234/transitions").to_return(:status => 204)
    end

    it "sends data to the correct resource" do
      JiraClient.resolve_issue "PROJECT-1234"
      expect(a_post('/issue/PROJECT-1234/transitions')).to have_been_made
    end
    it "sends the correct transition ID" do
      JiraClient.resolve_issue "PROJECT-1234"
      expect(a_post('/issue/PROJECT-1234/transitions').with(:body => transition_to(JiraClient::Status::RESOLVE))).to have_been_made
    end
    it "sends the resolution if provided" do
      JiraClient.resolve_issue "PROJECT-1234", :as => "Won't Fix"
      expect(a_post('/issue/PROJECT-1234/transitions').with(:body => transition_to(JiraClient::Status::RESOLVE, :resolution => "Won't Fix"))).to have_been_made
    end
    it "sends a comment if provided" do
      JiraClient.resolve_issue "PROJECT-1234", :comment => "This is a comment"
      expect(a_post('/issue/PROJECT-1234/transitions').with(:body => transition_to(JiraClient::Status::RESOLVE, :comment => "This is a comment"))).to have_been_made
    end
    it "sends both a comment and a resolution if provided" do
      JiraClient.resolve_issue "PROJECT-1234", :as => "Can't Reproduce", :comment => "This is a comment"
      expect(a_post('/issue/PROJECT-1234/transitions').with(:body => transition_to(JiraClient::Status::RESOLVE, :comment => "This is a comment", :resolution => "Can't Reproduce"))).to have_been_made
    end
  end

  describe "#close_issue" do

    before do
      stub_post("/issue/PROJECT-1234/transitions").to_return(:status => 204)
    end

    it "sends data to the correct resource" do
      JiraClient.close_issue "PROJECT-1234"
      expect(a_post('/issue/PROJECT-1234/transitions')).to have_been_made
    end
    it "sends the correct transition ID" do
      JiraClient.close_issue "PROJECT-1234"
      expect(a_post('/issue/PROJECT-1234/transitions').with(:body => transition_to(JiraClient::Status::CLOSE))).to have_been_made
    end
    it "sends a comment if provided" do
      JiraClient.close_issue "PROJECT-1234", :comment => "This is a comment"
      expect(a_post('/issue/PROJECT-1234/transitions').with(:body => transition_to(JiraClient::Status::CLOSE, :comment => "This is a comment"))).to have_been_made
    end
  end

  describe "#reopen_issue" do

    before do
      stub_post("/issue/PROJECT-1234/transitions").to_return(:status => 204)
    end

    it "sends data to the correct resource" do
      JiraClient.reopen_issue "PROJECT-1234"
      expect(a_post('/issue/PROJECT-1234/transitions')).to have_been_made
    end
    it "sends the correct transition ID" do
      JiraClient.reopen_issue "PROJECT-1234"
      expect(a_post('/issue/PROJECT-1234/transitions').with(:body => transition_to(JiraClient::Status::REOPEN))).to have_been_made
    end
    it "sends a comment if provided" do
      JiraClient.reopen_issue "PROJECT-1234", :comment => "This is a comment"
      expect(a_post('/issue/PROJECT-1234/transitions').with(:body => transition_to(JiraClient::Status::REOPEN, :comment => "This is a comment"))).to have_been_made
    end
  end

  describe "#start_progress_on_issue" do

    before do
      stub_post("/issue/PROJECT-1234/transitions").to_return(:status => 204)
    end

    it "sends data to the correct resource" do
      JiraClient.start_progress_on_issue "PROJECT-1234"
      expect(a_post('/issue/PROJECT-1234/transitions')).to have_been_made
    end
    it "sends the correct transition ID (6)" do
      JiraClient.start_progress_on_issue "PROJECT-1234"
      expect(a_post('/issue/PROJECT-1234/transitions').with(:body => transition_to(JiraClient::Status::START_PROGRESS))).to have_been_made
    end
    it "sends a comment if provided" do
      JiraClient.start_progress_on_issue "PROJECT-1234", :comment => "This is a comment"
      expect(a_post('/issue/PROJECT-1234/transitions').with(:body => transition_to(JiraClient::Status::START_PROGRESS, :comment => "This is a comment"))).to have_been_made
    end
  end

  describe "#find_issues" do

    before do
      stub_post("/search").with(:body => {:jql => "project = TEST"}).to_return(:status => 200, :body => fixture("issues.json"))
      @issues = JiraClient.find_issues(:jql => "project = TEST")
    end

    it "requests the correct resource" do
      expect(a_post("/search").with(:body => {"jql" => "project = TEST"})).to have_been_made
    end
    it "accepts an array of fields to be returned" do
      stub_post("/search").with(:body => {:fields => ["summary", "description"]}).to_return(:status => 200, :body => fixture("issues.json"))
      @issues = JiraClient.find_issues(:fields => [:summary, :description])
      expect(a_post("/search").with(:body => {:fields => ["summary", "description"]})).to have_been_made
    end
    it "returns an array of issue objects" do
      @issues.should be_a_kind_of Array
      @issues.each do |issue|
        issue.should be_a_kind_of JiraClient::Issue
      end
    end
    context "when there are no results" do

      before do
        stub_post("/search").with(:body => {:jql => "project = TEST and status = 'In Progress'"}).to_return(:status => 200, :body => fixture("no_issues_found.json"))
      end

      it "returns an empty array" do
        @issues = JiraClient.find_issues(:jql => "project = TEST and status = 'In Progress'")
        @issues.should be_a_kind_of Array
        @issues.should be_empty
      end
    end
    context "when there is a problem with the JQL" do

      before do
        stub_post("/search").with(:body => {:jql => "project = DOESNT_EXIST"}).to_return(:status => 400, :body => fixture("invalid_jql.json"))
      end

      it "raises a bad request error" do
        expect { JiraClient.find_issues(:jql => "project = DOESNT_EXIST") }.to raise_error(JiraClient::Error::BadRequest)
      end
      it "hints at the problem with the jql" do
        begin
          JiraClient.find_issues(:jql => "project = DOESNT_EXIST")
        rescue JiraClient::Error::BadRequest => e
          e.message.should include "project"
          e.message.should include "DOESNT_EXIST"
          e.message.should include "does not exist"
        end
      end
    end

  end

private

  def transition_to(id, opts = {})
    body = {"transition" => {"id" => id}}
    body["update"] = {"comment" => [{"add" => {"body" => opts[:comment]}}]} if opts.has_key? :comment
    body["fields"] = {"resolution" => {"name" => opts[:resolution]}} if opts.has_key? :resolution
    body
  end

end
