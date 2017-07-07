# See spec/helpers.rb for the definitions of the utility methods used here

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

    let(:invalid_params) { Hash.new }

    let(:response_to_query_with_valid_params) do
      send_email_with_curl_and_one_off_server(valid_params)
    end

    let(:response_to_query_with_invalid_params) do
      send_email_with_curl_and_one_off_server(invalid_params)
    end

    describe "basic endpoint functionality over CURL" do

      context "with valid params" do
        it "returns a JSON-encoded object" do
          expect(response_to_query_with_valid_params[:response]).to be_a Hash
        end
      end

      context "with invalid params" do
        it "still returns a JSON-encoded object" do
          expect(response_to_query_with_invalid_params[:response]).to be_a Hash
        end
      end

    end

    describe "status codes" do

      context "with valid params" do
        it "returns 200" do
          expect(response_to_query_with_valid_params[:status_code]).to eq 200
        end
      end

      context "with invalid params" do
        it "returns 422" do
          expect(response_to_query_with_invalid_params[:status_code]).to eq 422
        end
      end

    end

  end
end