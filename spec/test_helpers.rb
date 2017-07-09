require 'socket' # from Ruby Std-lib, provides TCPServer
require 'byebug' # debugger


# Global test helpers are provided via a refinement on Object
# Load them with this placed somewhere other than a method:
#    using TestHelpers
module TestHelpers
  refine Object do

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
        sleep 2 # TODO: remove this
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
          params: params
        )
      end
    end

  end
end