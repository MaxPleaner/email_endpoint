require 'mechanize' # HTTP Client with HTML parser

# The (constant) http client
# Wrapper over Mechanize
class HttpClient

  # A shared instance of the Mechanize HTTP Client
  Agent = Mechanize.new

  # @param type [Symbol] a HTTP request type e.g. :get or :post
  # @param url [String] should already have params appended if there are any
  # @return Hash with keys:
  #   status_code: Integer
  #   response (Hash, if the endpoint works as expected)  
  # If the response isn't JSON, this will raise a JSON::ParserError
  def self.request(type, url)
    result = Agent.send(type, url)
    response = JSON.parse result.body
    { response: response, status_code: result.code.to_i } 
  rescue Mechanize::ResponseCodeError => e
    { response: {}, status_code: e.response_code.to_i }
  end

end
