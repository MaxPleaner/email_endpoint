class EmailProviders

  class SendGridAPI < EmailProvider::Protocol

    # allows :SendGridAPI to be passed to EmailProvider#initialize
    EmailProvider.register(self)

    ApiKey = ENV.fetch("SENDGRID_API_KEY")

    Endpoint = ""
    
    Headers = {
      "Authorization" => "Bearer #{ApiKey}",
      "Content-Type" => "application/json",
    }

    # see {EmailProvider::Protocol#send_email}
    def self.send_email(params)
      { status_code: 200, response: {} }
    end

    class << self
      private
      def deliver_post_request(params)
        HttpRequest(
          :post,
          Endpoint,
          params: format_params(params),
          headers: Headers
        )
      end
      def self.format_params(params)
        byebug
        {
          "personalizations" => [
            {"to": ["email": params]}
          ]
        }
      end
    end


  # curl --request POST \
  # --url https://api.sendgrid.com/v3/mail/send \
  # --header "Authorization: Bearer $SENDGRID_API_KEY" \
  # --header 'Content-Type: application/json' \
  # --data '{"personalizations": [{"to": [{"email": "test@example.com"}]}],"from": {"email": "test@example.com"},"subject": "Sending with SendGrid is Fun","content": [{"type": "text/plain", "value": "and easy to do anywhere, even with cURL"}]}'

  end

end