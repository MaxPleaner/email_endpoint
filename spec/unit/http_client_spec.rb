RSpec.describe "HttpClient" do

  it "has constants" do
    expect(HttpClient::Agent).to be_a(Mechanize)
  end

  context ".request" do

    describe "GET requests" do
      it "returns the response body unchanged and correct status code" do
        url, referrer, params, headers = "", nil, {}, {}
        expect(HttpClient).to(
          receive(:get_request).with(url, params, referrer, headers)
        ).and_call_original
        expect(HttpClient::Agent).to(
          receive(:get).with(url, referrer, params, headers)
        ).and_return(
          OpenStruct.new(body: "unchanged", code: 202)
        )
        expect(
          HttpClient.request(:get, url, params: params)
        ).to(include(status_code: 202, response: "unchanged"))
      end
      it "returns status codes even if they are not succesful" do
        url, referrer, params, headers = "", nil, {}, {}
        expect(HttpClient).to(
          receive(:get_request).with(url, params, referrer, headers)
        ).and_call_original
        expect(HttpClient::Agent).to(
          receive(:get).with(url, referrer, params, headers)
        ).and_return(
          OpenStruct.new(body: "unchanged", code: 422)
        )
        expect(
          HttpClient.request(:get, url, params: params)
        ).to(include(status_code: 422, response: "unchanged"))        
      end
    end

    describe "POST requests" do
      it "returns the response body unchanged and correct status code" do
        url, referrer, params, headers = "", nil, {}, {}
        expect(HttpClient).to(
          receive(:post_request).with(url, params, referrer, headers)
        ).and_call_original
        expect(RestClient).to(
          receive(:post).with(url, params, headers)
        ).and_return(
          OpenStruct.new(body: "unchanged", code: 202)
        )
        expect(
          HttpClient.request(:post, url, params: params)
        ).to(include(status_code: 202, response: "unchanged"))        
      end
      it "returns status codes even if they are not succesful" do
        url, referrer, params, headers = "", nil, {}, {}
        expect(HttpClient).to(
          receive(:post_request).with(url, params, referrer, headers)
        ).and_call_original
        expect(RestClient).to(
          receive(:post).with(url, params, headers)
        ).and_return(
          OpenStruct.new(body: "unchanged", code: 422)
        )
        expect(
          HttpClient.request(:post, url, params: params)
        ).to(include(status_code: 422, response: "unchanged"))          
      end
    end

  end

  describe ".request_returning_parsed_json" do
    it "does the same thing as #request, but parses the json response body" do
      url, referrer, params, headers = "", nil, {}, {}
      expect(HttpClient).to(
        receive(:get_request).with(url, params, referrer, headers)
      ).and_call_original
      expect(HttpClient::Agent).to(
        receive(:get).with(url, referrer, params, headers)
      ).and_return(
        OpenStruct.new(body: {foo: "bar"}.to_json, code: 202)
      )
      expect(
        HttpClient.request_returning_parsed_json(:get, url, params: params)
      ).to(include(status_code: 202, response: {"foo" => "bar" }))        
    end
    it "raises an error if the body isn't valid json" do
      url, referrer, params, headers = "", nil, {}, {}
      expect(HttpClient).to(
        receive(:get_request).with(url, params, referrer, headers)
      ).and_call_original
      expect(HttpClient::Agent).to(
        receive(:get).with(url, referrer, params, headers)
      ).and_return(
        OpenStruct.new(body: "", code: 202)
      )
      expect do
        HttpClient.request_returning_parsed_json(:get, url, params: params)
      end.to(raise_error JSON::ParserError)
    end
  end

  describe ".get_request" do
    it "calls Mechanize#get" do
      url, params, referrer, headers = 4.times.map { {} }
      expect(HttpClient::Agent).to receive(:get).with(url, referrer, params, headers)
      HttpClient.send(:get_request, url, params, referrer, headers)
    end
  end

  describe ".post_request" do
    it "calls RestClient#post" do
      url, params, referrer, headers = 4.times.map { {} }
      expect(RestClient).to receive(:post).with(url, params, headers)
      HttpClient.send(:post_request, url, params, referrer, headers)
    end
    it "follows redirects" do
      url, params, referrer, headers = 4.times.map { {} }
      response = double
      expect(RestClient).to receive(:post).and_raise(
        RestClient::MovedPermanently.new(response)
      )
      expect(response).to receive(:follow_redirection)
      HttpClient.send(:post_request, url, params, referrer, headers)
    end
  end

  describe ".build_response" do
    it "turns sequential args into a hash and converts the status code to int" do
      response, code = {}, "1"
      expect(HttpClient.send(:build_response, response, code)).to include(
        response: response, status_code: 1
      )
    end
  end

end