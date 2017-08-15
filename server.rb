require 'sinatra'

require_relative 'models'
require_relative 'tokenbucket'
require_relative 'mock_data'

$bucket = TokenBucket.new(r: 1, b: 5)

get "/" do
    $bucket.accept_request? ? send_file('index.html') : status(503)
end

get "/menu/:id?" do
    content_type :json
    Menu.new(params['id']).to_json
end
