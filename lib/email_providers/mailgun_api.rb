class EmailProviders

  class MailGunAPI < EmailProvider::Protocol

    # allows :MailGunAPI to be passed to EmailProvider#initialize
    EmailProvider.register(self)

    ApiKey = ENV.fetch("MAILGUN_API_KEY")
    DomainName = ENV.fetch("MAILGUN_DOMAIN_NAME")
    Endpoint = "https://api:#{ApiKey}@api.mailgun.net/v3/#{DomainName}/messages"

    # see {EmailProvider::Protocol#send_email}
    # The response here is just an empty hash.
    # The status code speaks for itself.
    def self.send_email(params)
      HttpClient.request_returning_status_code_only(
        :post,
        Endpoint,
        params: format_params(params),
      )
    end

    class << self
      private
      def format_params(params)
        {
          from: params[:from],
          to: params[:to],
          subject: params[:subject],
          text: params[:sanitized_html]
        }
      end
    end

  end

end