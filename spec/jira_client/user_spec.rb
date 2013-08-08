describe JiraClient::User do
    describe "#to_s" do
        let(:user) { JiraClient::User.from_response({:display_name => "Name"})}

        it "prints the user's display name" do
            user.to_s.should == "Name"
        end
    end
end
