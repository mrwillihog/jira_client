require "spec_helper"

describe JiraClient::API::Users do

  describe "#find_user_by_username" do

    before do
      stub_get("/user?username=admin").to_return(:body => fixture("admin.json"))
      @user = JiraClient.find_user_by_username "admin"
    end

    it "requests the correct resource" do
      expect(a_get("/user?username=admin")).to have_been_made
    end
    it "returns a JiraClient::User object" do
      @user.should be_a_kind_of JiraClient::User
    end
    it "sets the correct attributes" do
      @user.display_name.should == "admin"
      @user.should be_active
      @user.email_address.should == "admin@example.com"
    end

    describe "when the user can't be found" do

      before do
        stub_get("/user?username=doesnt_exist").to_return(:status => 404, :body => fixture("user_doesnt_exist.json"))
      end

      it "raises a not found error" do
        expect { JiraClient.find_user_by_username("doesnt_exist") }.to raise_error(JiraClient::Error::ResourceNotFound)
      end
    end
  end

  describe "#find_users" do

    before do
      stub_get("/user/search?username=test").to_return(:status => 200, :body => fixture("users.json"))
      @users = JiraClient.find_users("test")
    end

    it "requests the correct resource" do
      expect(a_get("/user/search?username=test")).to have_been_made
    end
    it "returns the correct number of results" do
      @users.size.should == 2
    end
    it "returns user objects" do
      @users.each do |user|
        user.should be_a_kind_of JiraClient::User
      end
    end
  end

end