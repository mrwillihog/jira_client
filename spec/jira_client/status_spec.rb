describe JiraClient::Status do
    describe "#to_s" do
        let(:status) { JiraClient::Status.from_response({ :name => "Status" })}

        it "prints the status' name" do
            status.to_s.should == "Status"
        end
    end
end
