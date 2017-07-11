RSpec.describe "HttpClient" do

  it "has constants" do
    expect(HttpClient::Agent).to be_a(Mechanize)
  end

  describe ".request" do

    context "GET requests" do
      it "uses Mechanize and returns the response body unchanged" do
        url, referrer, params, headers = "", nil, {}, {}
        expect(HttpClient).to(
          receive(:get_request).with(url, params, referrer, headers)
        ).and_call_original
        expect(HttpClient::Agent).to(
          receive(:get).with(url, referrer, params, headers)
        ).and_return(
          OpenStruct.new(body: "", code: 202)
        )
        expect(
          HttpClient.request(:get, url, params: params)
        ).to(include(status_code: 202, response: ""))

      end
      it "returns status codes even if they are not succesful" do
      end
    end

    context "POST requests" do
      it "uses RestClient" do
      end
      it "returns status codes even if they are not succesful" do
      end
    end

  end

end