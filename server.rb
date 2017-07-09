require 'sinatra/base'
require 'active_support/all'
require 'json'
require 'dotenv'

# Load environment variables from .env file
Dotenv.load 

require_relative './lib/email_sender.rb'
require_relative './lib/http_client.rb'

# Backport Kernel#yield_self which was added to Ruby 2.5 
defined?(yield_self) || (module Kernel; def yield_self; yield(self); end; end)

class Server < Sinatra::Base

  # Parse JSON request bodies
  # Credit: https://stackoverflow.com/a/17049683/2981429
  before do
    request.body.rewind
    payload = JSON.parse(request.body.read)
    request.define_singleton_method(:payload, ->{payload})
  end

  post '/email' do
    result = EmailSender.run(request)
    status result[:status_code]
    content_type "application/json"
    result[:response].to_json
  rescue => e # Rescue most exceptions to prevent application
              # details leaking
    puts e.class, e, e.backtrace
    status 500
    content_type "application/json"
    { errors: "Not sure what happened there." }.to_json
  end

end