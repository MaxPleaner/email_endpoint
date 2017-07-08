require 'socket' # from Ruby Std-lib, provides TCPServer
require 'byebug' # debugger


# Global test helpers are provided via a refinement on Object
# Load them with this placed somewhere other than a method:
#    using TestHelpers
module TestHelpers
  refine Object do

    # Runs a server in a background thread and closes it when the block is done
    # @yield [base_url]
    # @return the result of the yield
    def with_running_server(&blk)
      port = find_open_port
      thread = Thread.new { `rackup -p #{port} &> /dev/null` }
      sleep 2 # TODO: remove this
      blk.call("http://localhost:#{port}").tap { thread.kill }
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
    def send_email_with_curl_and_one_off_server(params)
      with_running_server do |base_url|
        endpoint = "#{base_url}/email?#{params.to_query}"
        curl_post_with_status_code(endpoint)
      end
    end

    # @param endpoint [String] should already have params appended if there are any
    # @return Hash with keys:
    #   status_code: Integer
    #   response (Hash, if the endpoint works as expected)
    def curl_post_with_status_code(endpoint)
      HttpClient.request :post, endpoint
    end

  end
end