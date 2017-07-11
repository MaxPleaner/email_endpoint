# Fake classes
class ValidFakeProvider < EmailProvider::Protocol
  Response = {status_code: 202, response: {}}
  def self.send_email(params); Response; end
end
class InvalidFakeProvider < EmailProvider::Protocol
end

RSpec.describe "EmailProvider" do

  describe "using child classes with a protocol" do
    it "tracks providers in a constant" do
      expect(EmailProvider::Providers).to be_a(Hash)
    end

    it "allows providers to add themselves to it" do
      EmailProvider.register(ValidFakeProvider)
      expect(EmailProvider::Providers[:ValidFakeProvider]).to eq(ValidFakeProvider)
    end

    it "can use registered providers in #initialize" do
      EmailProvider.register(ValidFakeProvider)
      provider = EmailProvider.new(:ValidFakeProvider)
      expect(provider.send_email({})).to eq ValidFakeProvider::Response
    end

    it "will raise an error if the provider doesn't respond to .send_email" do
      EmailProvider.register(InvalidFakeProvider)
      provider = EmailProvider.new(:InvalidFakeProvider)
      expect do 
        provider.send_email({})
      end.to raise_error(EmailProvider::Protocol::MethodNotImplementedError)
    end

  end

end