
# just testing

require 'rubygems'
require 'lib/rufus/sixjo'

module ExampleOne

  extend Rufus::Sixjo

  get '/toto' do
    "nada at #{request.path_info}"
  end
end

app = Rack::Builder.new do

  use Rack::CommonLogger
  use Rack::ShowExceptions
  run ExampleOne.new_sixjo_rack_app(nil)
end

Rack::Handler::Mongrel.run app, :Port => 2042 # 1021 * 2

