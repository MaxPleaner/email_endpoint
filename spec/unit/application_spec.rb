RSpec.describe "Application" do

  describe "Environment Variables" do

    it "requires that certain ones are set" do
      expect(%w{
        MAILGUN_API_KEY
        MAILGUN_DOMAIN_NAME
        SENDGRID_API_KEY
        TEST_EMAIL_USERNAME
        TEST_EMAIL_PASSWORD
      }.map(&ENV.method(:[])).none? &:blank?).to be true
    end

  end

end