describe JiraClient::ServerInfo do

    describe "#to_s" do
        let(:server_info) { JiraClient::ServerInfo.from_response({:base_url => "url", :version => "version"})}

        it "prints the base url and version" do
            server_info.to_s.should include "url"
            server_info.to_s.should include "version"
        end
    end

end
