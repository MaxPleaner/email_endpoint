using TestHelpers

RSpec.describe "MailGunAPI" do

  let(:mailgun_api) { EmailProviders::MailGunAPI }
  let(:params) { valid_params_with_sanitized_html }

  it "defines some constants" do
    %i{
      ApiKey DomainName Endpoint
    }.map(&mailgun_api.method(:const_get)).each &not_blank!
  end

  describe "usage with EmailProvider::Protocol" do
    it "derives from EmailProvider::Protocol" do
      expect( mailgun_api < EmailProvider::Protocol).to be_truthy
    end
    it "is registered in EmailProvider::Providers" do
      expect(EmailProvider::Providers[:MailGunAPI]).to eq(mailgun_api)
      expect(EmailProvider.new(:MailGunAPI).provider).to eq(mailgun_api)
    end
  end

  describe ".format_params" do
    it "formats the params" do
      result = mailgun_api.send(:format_params, params)
      expected = format_mailgun_params(params)
      expect(result).to include(expected)
    end
  end

  describe ".send_email" do
    it "makes a request and returns status code" do
      stubbed_response = { status_code: 202, response: {} }
      stub_post(
        mailgun_api::Endpoint,
        format_mailgun_params(params),
        response: stubbed_response,
      )
      expect(mailgun_api.send_email(params)).to include(stubbed_response)
    end

  end

end
