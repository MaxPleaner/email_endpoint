using TestHelpers

RSpec.describe "EmailSender" do
  
  it "defines a default provider name, loaded from env vars" do
    expect(EmailSender::DefaultProviderName.tap &not_blank!).to be_a Symbol
  end

  describe ".run" do
    it "sends an email when given valid params" do
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
    it "returns an error code when given invalid params" do
      request = double
      provider_name = EmailSender::DefaultProviderName
      expect(request).to receive(:payload).and_return(invalid_params)
      expect(EmailSender).not_to(receive(:send_email))
      result = EmailSender.run request, provider_name
      expect(result).to include(
        status_code: 422
      )
      valid_params.keys.each do |key|
        expect(result[:response][key.to_sym]).to include("no value given")
      end
    end
  end

end