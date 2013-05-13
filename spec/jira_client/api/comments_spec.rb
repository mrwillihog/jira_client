require "spec_helper"

describe JiraClient::API::Comments do

  describe "#find_issue_comments" do

    before do
      stub_get("/issue/PROJECT-1234/comment").to_return(:body => fixture("comments.json"), :headers => {:content_type => "application/json; charset=utf-8"})
      @comments = JiraClient.find_issue_comments "PROJECT-1234"
    end

    it "requests the correct resource" do
      expect(a_get("/issue/PROJECT-1234/comment")).to have_been_made
    end
    it "returns an array of JiraClient::Comment objects" do
      @comments.should be_a_kind_of Array
      @comments.each do |comment|
        comment.should be_a_kind_of JiraClient::Comment
      end
    end
    it "assigns the correct information" do
      comment = @comments.first
      comment.body.should == "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque eget venenatis elit. Duis eu justo eget augue iaculis fermentum. Sed semper quam laoreet nisi egestas at posuere augue semper."
      comment.author.should be_a_kind_of JiraClient::User
      comment.update_author.should be_a_kind_of JiraClient::User
      comment.created.should be_a_kind_of DateTime
      comment.updated.should be_a_kind_of DateTime
    end
  end

  describe "#comment_on_issue" do

    before do
      stub_post("/issue/PROJECT-1234/comment").with(:body => {"body" => "This is a comment"}).to_return(:status => 201, :body => fixture("comment.json"))
      @comment = JiraClient.comment_on_issue("PROJECT-1234", "This is a comment")
    end

    it "requests the correct resource" do
      expect(a_post("/issue/PROJECT-1234/comment").with(:body => {:body => "This is a comment"})).to have_been_made
    end
    it "returns the comment object" do
      @comment.should be_a_kind_of JiraClient::Comment
    end
    it "with the comment text set on the comment object" do
      @comment.body.should == "This is a comment"
    end
    context "without a comment body" do

      before do
        stub_post("/issue/PROJECT-1234/comment").to_return(:status => 400, :body => fixture("invalid_comment.json"))
      end

      it "raises a JiraClient::Error::BadRequest" do
        expect { JiraClient.comment_on_issue("PROJECT-1234", "") }.to raise_error(JiraClient::Error::BadRequest)
      end
    end
  end

end