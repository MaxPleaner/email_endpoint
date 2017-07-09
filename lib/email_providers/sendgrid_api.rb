class EmailProviders

  class SendGridAPI < EmailProvider::Protocol

    # allows :SendGridAPI to be passed to EmailProvider#initialize
    EmailProvider.register(self)

    ApiKey = ENV.fetch("SENDGRID_API_KEY")

    Endpoint = "http://api.sendgrid.com/v3/mail/send"
    
    Headers = {
      "Authorization" => "Bearer #{ApiKey}",
      "Content-Type" => "application/json",
    }

    # see {EmailProvider::Protocol#send_email}
    def self.send_email(params)
      HttpClient.request(
        :post,
        Endpoint,
        params: format_params(params),
        headers: Headers
      )
    end

    class << self
      private
      def format_params(params)
        {
          "personalizations" => [
            {"to" => ["email" => params[:to]]}
          ],
          "from" => { "email" => params[:from] },
          "subject" => params[:subject],
          "content" => [{
            "type" => "text/plain",
            "value" => params[:sanitized_html]
          }]
        }
      end
    end

  end

end