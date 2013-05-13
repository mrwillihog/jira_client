require "spec_helper"

describe JiraClient::API::Worklogs do

  describe "#create_worklog" do

    before do
      stub_post("/issue/PROJECT-1234/worklog").to_return(:status => 201)
    end

    it "requests the correct resource" do
      JiraClient.create_worklog("PROJECT-1234", "30m")
      expect(a_post("/issue/PROJECT-1234/worklog")).to have_been_made
    end

    describe "Parsing duration strings" do
      it "understands 30m" do
        JiraClient.create_worklog("PROJECT-1234", "30m")
        expect(a_post("/issue/PROJECT-1234/worklog").with(:body => {:timeSpentSeconds => 1800})).to have_been_made
      end
      it "understands 1h30m" do
        JiraClient.create_worklog("PROJECT-1234", "1h30m")
        expect(a_post("/issue/PROJECT-1234/worklog").with(:body => {:timeSpentSeconds => 5400})).to have_been_made
      end
      it "understands 1.5h" do
        JiraClient.create_worklog("PROJECT-1234", "1.5h")
        expect(a_post("/issue/PROJECT-1234/worklog").with(:body => {:timeSpentSeconds => 5400})).to have_been_made
      end
    end

    describe "Adjusting estimates" do
      it "can adjust remaining estimate to a specified amount" do
        stub_post("/issue/PROJECT-1234/worklog?adjustEstimate=new&newEstimate=1h").to_return(:status => 201)
        JiraClient.create_worklog("PROJECT-1234", "30m", :remaining_estimate => "1h")
        expect(a_post("/issue/PROJECT-1234/worklog?adjustEstimate=new&newEstimate=1h").with(:body => {:timeSpentSeconds => 1800})).to have_been_made
      end
      it "can adjust remaining estimate to zero" do
        stub_post("/issue/PROJECT-1234/worklog?adjustEstimate=new&newEstimate=0").to_return(:status => 201)
        JiraClient.create_worklog("PROJECT-1234", "30m", :remaining_estimate => 0)
        expect(a_post("/issue/PROJECT-1234/worklog?adjustEstimate=new&newEstimate=0")).to have_been_made
      end
      it "can manually reduce the estimate by a specified amount" do
        stub_post("/issue/PROJECT-1234/worklog?adjustEstimate=manual&reduceBy=1h").to_return(:status => 201)
        JiraClient.create_worklog("PROJECT-1234", "30m", :reduce_estimate => "1h")
        expect(a_post("/issue/PROJECT-1234/worklog?adjustEstimate=manual&reduceBy=1h")).to have_been_made
      end
    end

    describe "Commenting on work logs" do
      it "should be possible" do
        JiraClient.create_worklog("PROJECT-1234", "30m", :comment => "I did some work")
        expect(a_post("/issue/PROJECT-1234/worklog").with(:body => {:timeSpentSeconds => 1800, :comment => "I did some work"})).to have_been_made
      end
    end
  end

  describe "#find_issue_worklogs" do

    before do
      stub_get("/issue/PROJECT-1234/worklog").to_return(:body => fixture("worklog.json"))
      @worklogs = JiraClient.find_issue_worklogs("PROJECT-1234")
      @worklog = @worklogs.first
    end

    it "requests the correct resource" do
      expect(a_get("/issue/PROJECT-1234/worklog")).to have_been_made
    end
    it "returns an array of JiraClient::Worklog objects" do
      @worklogs.should be_a_kind_of Array
      @worklog.should be_a_kind_of JiraClient::Worklog
    end
    it "sets the correct attributes on the JiraClient::Worklog objects" do
      @worklog.time_spent.should == "3h 20m"
      @worklog.started.should == Time.parse("2012-02-15T17:34:37.937-0600")
      @worklog.time_spent_seconds.should == 12000
      @worklog.comment.should == "I did some work here."
    end
    it "parses the author as a JiraClient::User object" do
      @worklog.author.should be_a_kind_of JiraClient::User
    end
    it "parses the update author as a JiraClient::User object" do
      @worklog.update_author.should be_a_kind_of JiraClient::User
    end
  end

end