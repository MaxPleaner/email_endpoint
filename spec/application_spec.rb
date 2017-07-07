RSpec.describe "Application" do

  describe "Environment Variables" do

    it "requires that certain ones are set" do
      expect(%w{
        SENDGRID_API_KEY
      }.map(&ENV.method(:[])).none? &:blank?).to be true
    end

  end

end