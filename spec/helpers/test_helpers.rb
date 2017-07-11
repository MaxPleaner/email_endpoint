require 'socket' # from Ruby Std-lib, provides TCPServer

# Global test helpers are provided via a refinement on Object
# Load them with this placed somewhere other than a method:
#    using TestHelpers
module TestHelpers
  refine Object do

    # @yield iteratee
    # Usage: nil.tap(&not_blank?)
    # the above example will raise an ExpectationNotMet error
    def not_blank!
      Proc.new { |x| expect(x.blank?).to be false }
    end

    # Format parameters in the way required by the mailgun API
    # This mirrors EmailProviders::MailGunAPI.format_params
    # @param [Hash]
    # @return [Hash]
    def format_mailgun_params(params)
      {
        from: params[:from].tap(&not_blank!),
        to: params[:to].tap(&not_blank!),
        subject: params[:subject].tap(&not_blank!),
        text: params[:sanitized_html].tap(&not_blank!)
      }
    end

    # Format parameters in the way required by Sendgrid's API
    # This mirrors EmailProviders::SendGridAPI.format_params
    # @param [Hash]
    # @return [Hash]
    def format_sendgrid_params(params)
      {
        "personalizations" => [
          {"to" => ["email" => params[:to].tap(&not_blank!)]}
        ],
        "from" => { "email" => params[:from].tap(&not_blank!) },
        "subject" => params[:subject].tap(&not_blank!),
        "content" => [{
          "type" => "text/plain",
          "value" => params[:sanitized_html].tap(&not_blank!)
        }]
      }      
    end

    # stubs the HttpClient.request's POST call
    # @param endpoint [String] a url
    # @param params [Hash]
    # @keyword response [Hash] should have status_code and response keys
    def stub_post(endpoint, params, response:, headers: {})
      opts = { params: params}.yield_self do |hash|
        headers.blank? ? hash : hash.merge(headers: headers)
      end
      allow(HttpClient).to(
        receive(:request).with(:post, endpoint, opts)
      ).and_return(response)
    end

    # Valid parameters for POST /email
    # @return [Hash]
    def valid_params
      {
        "to" => "#{ENV.fetch("TEST_EMAIL_USERNAME")}@gmail.com",
        "to_name" => "Mr. Fake",
        "from" => "noreply@mybrightwheel.com",
        "from_name" => "Brightwheel",
        "subject" => "A message from Brightwheel",
        "body" => "<h1> Your bill</h1><p> $10</p>"
      }.with_indifferent_access
    end

    # valid_params with sanitized_html key set
    # @return [Hash]
    def valid_params_with_sanitized_html
      valid_params.yield_self do |params|
        params.merge(
          sanitized_html: EmailSender.sanitize_html(params[:body])
        )
      end
    end

    # Invalid parameters for POST /email
    # @return [Hash]
    def invalid_params
      {}
    end

    # @yield [SmtpServer] instance.
    def with_smtp_server(&blk)
      blk.call SmtpServer.new(*(%w{
        TEST_EMAIL_USERNAME TEST_EMAIL_PASSWORD  
      }.map &ENV.method(:fetch)))
    end

    # If ENV["SERVER_URL"] is set, the block is invoked and passed that url.
    # Otherwise, a temporary server in a background thread gets launched,
    # and its' url passed to the block before it's closed. 
    # @yield [base_url]
    # @return the result of the yield
    def with_running_server(&blk)
      if url = ENV["SERVER_URL"]
        blk.call(url)
      else
        port = find_open_port
        thread = Thread.new { `rackup -p #{port}` }
        sleep 2 # Give server time to launch
        blk.call("http://localhost:#{port}").tap { thread.kill }
      end
    end

    private

    # @return port_number [Integer] which is available for a TCP server to use
    #   Thanks to https://stackoverflow.com/a/201528/2981429 for this 
    def find_open_port
      server = TCPServer.new('127.0.0.1', 0)
      server.addr[1].to_i.tap { server.close }
    end

    # Sends an email using POST /email
    # @param params [Hash] converted to a query string
    # @return [Hash] with keys:
    #   status_code (Integer)
    #   response (Hash, if the endpoint works as expected)
    def send_email_with_local_server(params)
      with_running_server do |base_url|
        HttpClient.request_returning_parsed_json(
          :post,
          "#{base_url}/email",
          params: params.to_json
        )
      end
    end

  end
end