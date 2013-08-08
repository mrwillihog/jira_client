describe JiraClient::Project do
    describe "#to_s" do
        let(:project) { JiraClient::Project.from_response({:name => "Project"}) }

        it "prints the project name" do
            project.to_s.should == "Project"
        end
    end
end
