RSpec.describe "MailgunAPI" do

  let(:mailgun_api) { EmailProviders::MailGunAPI }

  let(:expected_formatted_params) do |params|
    {
      from: params[:from],
      to: params[:to],
      subject: params[:subject],
      text: params[:sanitized_html]
    }
  end

  describe "usage with EmailProvider::Protocol" do
    it "derives from EmailProvider::Protocol" do
      expect( mailgun_api < EmailProvider::Protocol).to be_truthy
    end
    it "is registered in EmailProvider::Providers" do
      expect(EmailProvider::Providers[:MailgunAPI]).to eq(mailgun_api)
      expect(EmailProvider.new(:MailgunAPI).provider).to eq(mailgun_api)
    end
  end

  describe "constants" do
    it "defines some of them" do
      expect(%i{
        ApiKey DomainName Endpoint
      }.map(&mailgun_api.method(:const_get)).none(&:blank?)).to be true
    end
  end

  context ".format_params" do
    it "formats the params" do
      result = MailGunAPI.format_params(valid_params_with_sanitized_html)
      expected = expected_formatted_params(valid_params_with_sanitized_html)
      expect(result).to include(expected)
    end
  end

  context ".send_email" do
    it "makes a request and returns status code" do
      stubbed_response = { status_code: 202, response: {} }
      stub_post(
        mailgun_api::Endpoint,
        expected_formatted_params({}),
        response: stubbed_response
      )
      expect(MailGunAPI.send_email({}).to include(stubbed_response))
    end

  end

end