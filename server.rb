require 'sinatra/base'

class Server < Sinatra::Base

  get '/' do
    'hello world'
  end
  
end