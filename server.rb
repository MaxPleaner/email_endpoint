require 'sinatra/base'
require 'active_support/all'
require 'json'

require_relative './lib/email_processor.rb'

class Server < Sinatra::Base

  post '/email' do
    result = EmailProcessor.run(request)
    status_code result[:status_code]
    content_type "application/json"
    result[:response].to_json
  end

end