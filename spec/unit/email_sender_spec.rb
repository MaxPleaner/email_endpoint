using TestHelpers

RSpec.describe "EmailSender" do
  
  it "defines a default provider name, loaded from env vars" do
    expect(EmailSender::DefaultProviderName.tap &not_blank!).to be_a Symbol
  end

  describe ".run" do
    it "sends an email when given params" do
      request = double
      provider_name = EmailSender::DefaultProviderName
      expect(request).to receive(:payload).and_return(valid_params)
      expect(EmailSender).to(
        receive(:send_email).with(any_args).and_return(
          status_code: 202, response: "foo"
        )
      )
      expect(EmailSender.run request, provider_name).to include(
        status_code: 202, response: "foo"
      )
    end
  end

end