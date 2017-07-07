RSpec.describe "API" do

  context "POST /email" do

    let(:valid_params) do
      {
        to: "fake@example.com",
        to_name: "Mr. Fake",
        from: "noreply@mybrightwheel.com",
        from_name: "Brightwheel",
        subject: "A message from Brightwheel",
        body: "<h1> Your bill</h1><p> $10</p>"
      }
    end
    let(:valid_params_string) { valid_params.to_query }
    let(:invalid_params) { {} }
    let(:invalid_params_string) { invalid_params.to_query }

    describe "basic endpoint functionality over CURL" do

      context "with valid params" do

        it "returns a JSON-encoded object" do
          with_running_server do |base_url|
            endpoint = "#{base_url}/email?#{valid_params_string}"
            response = JSON.parse `curl -X POST #{endpoint}`
            expect(response).to be_a Hash
          end
        end

      end

      context "with invalid params" do

        it "still returns a JSON-encoded object" do
          with_running_server do |base_url|
            endpoint = "#{base_url}/email?#{invalid_params_string}"
            response = JSON.parse `curl -X POST #{endpoint}`
            expect(response).to be_a Hash
          end
        end

      end

    end

  end
end