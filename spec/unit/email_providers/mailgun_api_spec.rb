using TestHelpers

RSpec.describe "MailgunAPI" do

  let(:mailgun_api) { EmailProviders::MailGunAPI }

  describe "usage with EmailProvider::Protocol" do
    it "derives from EmailProvider::Protocol" do
      expect( mailgun_api < EmailProvider::Protocol).to be_truthy
    end
    it "is registered in EmailProvider::Providers" do
      expect(EmailProvider::Providers[:MailGunAPI]).to eq(mailgun_api)
      expect(EmailProvider.new(:MailGunAPI).provider).to eq(mailgun_api)
    end
  end

  describe "constants" do
    it "defines some of them" do
      expect(%i{
        ApiKey DomainName Endpoint
      }.map(&mailgun_api.method(:const_get)).none?(&:blank?)).to be true
    end
  end

  context ".format_params" do
    it "formats the params" do
      result = mailgun_api.send(:format_params, valid_params_with_sanitized_html)
      expected = format_mailgun_params(valid_params_with_sanitized_html)
      expect(result).to include(expected)
    end
  end

  context ".send_email" do
    it "makes a request and returns status code" do
      stubbed_response = { status_code: 202, response: {} }
      stub_post(
        mailgun_api::Endpoint,
        format_mailgun_params({}),
        response: stubbed_response
      )
      expect(mailgun_api.send_email({})).to include(stubbed_response)
    end

  end

end