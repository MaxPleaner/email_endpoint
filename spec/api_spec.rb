RSpec.describe "API" do
  context "POST /email" do

    describe "basic endpoint functionality" do

      it "returns a JSON-encoded object when hit with CURL" do
        with_running_server do |base_url|
          response = JSON.parse `curl -X POST #{base_url}/email`
          expect(response).to be_a Hash
        end
      end

    end

  end
end