
# just testing

require 'rubygems'
require 'lib/rufus/sixjo'

extend Rufus::Sixjo

get '/toto' do
  "nada at #{request.path_info}"
end

six = new_sixjo_rack_app(nil)

app = Rack::Builder.new do

  use Rack::CommonLogger
  use Rack::ShowExceptions
  run six
end

Rack::Handler::Mongrel.run app, :Port => 2042 # 1021 * 2

