require 'sinatra/base'
require 'active_support/all'
require 'json'
require 'dotenv'

# Load environment variables from .env file
Dotenv.load 

require_relative './lib/email_processor.rb'
require_relative './lib/http_client.rb'

class Server < Sinatra::Base

  post '/email' do
    result = EmailProcessor.run(request)
    status result[:status_code]
    content_type "application/json"
    result[:response].to_json
  end

end