using TestHelpers

RSpec.describe "SendGridAPI" do

  let(:sendgrid_api) { EmailProviders::SendGridAPI }
  let(:params) { valid_params_with_sanitized_html }

  describe "usage with EmailProvider::Protocol" do
    it "derives from EmailProvider::Protocol" do
      expect(sendgrid_api < EmailProvider::Protocol).to be_truthy
    end
    it "is registered in EmailProvider::Providers" do
      expect(EmailProvider::Providers[:SendGridAPI]).to eq(sendgrid_api)
      expect(EmailProvider.new(:SendGridAPI).provider).to eq(sendgrid_api)
    end
  end

  describe "constants" do
    it "defines some of them" do
      %i{
        ApiKey Headers Endpoint
      }.map(&sendgrid_api.method(:const_get)).each &not_blank!
    end
  end

  context ".format_params" do
    it "formats the params" do
      result = sendgrid_api.send(:format_params, params)
      expected = format_sendgrid_params(params)
      expect(result).to include(expected)
    end
  end

  context ".send_email" do
    it "makes a request and returns status code" do
      stubbed_response = { status_code: 202, response: {} }
      stub_post(
        sendgrid_api::Endpoint,
        format_sendgrid_params(params).to_json,
        response: stubbed_response,
        headers: sendgrid_api::Headers
      )
      expect(sendgrid_api.send_email(params)).to include(stubbed_response)
    end

  end

end