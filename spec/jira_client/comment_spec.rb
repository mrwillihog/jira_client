describe JiraClient::Comment do

    describe "#to_s" do
        let(:comment) { JiraClient::Comment.from_response({:body => "Comment"})}

        it "prints the comment body" do
            comment.to_s.should == "Comment"
        end
    end

end
