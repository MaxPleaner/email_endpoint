class EmailProviders

  class SendGridAPI

    EmailProvider.register(self)

    # see {EmailProvider::Protocol#send_email}
    def self.send_email(endpoint)
      { status_code: 200, response: {} }
    end

  end

end