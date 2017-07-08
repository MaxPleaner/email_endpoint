require 'mechanize' # HTTP Client with HTML parser

# The (constant) http client
# Wrapper over Mechanize
class HttpClient

  # A shared instance of the Mechanize HTTP Client
  Agent = Mechanize.new

  # @param type [Symbol] a HTTP request type. One of :get or :post.
  # @param url [String] should already have params appended if there are any
  # @keyword params [Hash] defaults to {}
  # @keyword referrer [String], only used for :get
  # @keyword headers [Hash] defaults to {}
  # @return Hash with keys:
  #   status_code: Integer
  #   response (Hash, if the endpoint works as expected)  
  # If the response isn't JSON, this will raise a JSON::ParserError
  def self.request(type, url, params: {}, referrer: nil, headers: {})
    result = case type
    when :get
      Agent.send(type, url, referrer, params, headers)
    when :post
      Agent.send(type, url, params, headers)
    else
      raise(ArgumentError, "HttpClient.request can't handle type #{type}")
    end
    response = JSON.parse result.body
    { response: response, status_code: result.code.to_i } 
  rescue Mechanize::ResponseCodeError => e
    { response: {}, status_code: e.response_code.to_i }
  end

end
