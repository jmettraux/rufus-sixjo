
# just testing

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
  run ExampleOne.new_rack_application(nil)
end

Rack::Handler::Mongrel.run app, :Port => 2042 # 1021 * 2

