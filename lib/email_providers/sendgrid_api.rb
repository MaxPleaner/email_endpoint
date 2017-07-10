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
    # The response here is just an empty hash.
    # The status code speaks for itself.
    def self.send_email(params)
      HttpClient.request_returning_status_code_only(
        :post,
        Endpoint,
        params: format_params(params).to_json,
        headers: Headers
      )
    end

    class << self
      private
      def format_params(params)
        params = params.with_indifferent_access
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