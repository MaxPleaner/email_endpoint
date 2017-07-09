require 'mechanize' # HTTP Client with HTML parser
require 'rest-client'

# The (constant) http client
# Wrapper over Mechanize
class HttpClient

  # A shared instance of the Mechanize HTTP Client
  Agent = Mechanize.new

  # @param type [Symbol] a HTTP request type. One of :get or :post.
  # @param url [String] should include query params in a GET request
  # @keyword params [Hash] defaults to {}
  # @keyword referrer [String], only used for :get
  # @keyword headers [Hash] defaults to {}
  # @return Hash with keys:
  #   status_code: Integer
  #   response: String (possibly JSON)
  def self.request(type, url, params: {}, referrer: nil, headers: {})
    result = {
      get: method(:get_request),
      post: method(:post_request)
    }.fetch(type).call(url, params, referrer, headers)
    build_response result.body, result.code
  rescue Mechanize::ResponseCodeError => e
    build_response({}.to_json, e.response_code)
  rescue RestClient::ExceptionWithResponse => e
    build_response({}.to_json, e.http_code)
  end

  # Has the same signature as {.request},
  # but sets response: {} in the returned hash
  # (ignoring the actual response body)
  def self.request_returning_status_code_only(*args, **opts)
    request(*args, **opts).yield_self do |response|
      response.merge response: {}
    end
  end

  # Has the same signature as {.request},
  # but parses the response body (the 'response' key in the returned hash)
  def self.request_returning_parsed_json(*args, **opts)
    request(*args, **opts).yield_self do |response|
      response.merge response: JSON.parse(response[:response])
    end
  end

  class << self

    private

    def get_request(url, params, referrer, headers)
      Agent.get url, referrer, params, headers
    end

    def post_request(url, params, referrer, headers)
      RestClient.post url, params, headers
    rescue RestClient::MovedPermanently => e
      e.response.follow_redirection
    end

    def build_response(response, status_code)
      {response: response, status_code: status_code.to_i }
    end

  end

end
