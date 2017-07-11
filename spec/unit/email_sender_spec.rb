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

  describe ".sanitize_html" do
    it "removes html tags" do
      expect(EmailSender.sanitize_html("<p>foo</p>")).to eq("foo")
    end
  end

  describe "ParamValidations" do
    let(:validation_keys) { %i{to to_name from from_name subject body} }
    let(:validations) { EmailSender::ParamValidations }
    it "includes the expected keys" do
      expect(EmailSender::ParamValidations.keys).to include(*validation_keys)
    end
    it "returns an error message if any value is blank" do
      expect(
        validations.values_at(*validation_keys).map do |proc|
          proc.call(nil)
        end.all? { |errors| errors.include?("no value given") }
      ).to be true
    end
    describe "to and from validations" do
      it "returns an error message if an invalid email is given" do
        invalid_email = "foo"
        expect(
          validations.values_at(:to, :from).map do |proc|
            proc.call(invalid_email)
          end.all? { |errors| errors.include?("invalid email address") }
        ).to be true
      end
      it "returns no errors if a valid email is given" do
        valid_email = "maxpleaner@gmail.com"
        expect(
          validations.values_at(*validation_keys).map do |proc|
            proc.call(valid_email)
          end.all? { |errors| errors.empty? }
        ).to be true        
      end
    end
  end

end