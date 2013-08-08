describe JiraClient::Issue do
    describe "#to_s" do
        let(:issue) { JiraClient::Issue.from_response({:key => "key", :summary => "summary"})}

        it "prints the issue key and summary" do
            issue.to_s.should include "key"
            issue.to_s.should include "summary"
        end
    end
end
