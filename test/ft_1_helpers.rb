
#
# Testing rufus-sixjo
#
# jmettraux at gmail.org
#
# Sat Aug  9 00:03:47 JST 2008
#

require 'test/unit'
require 'testmixins'

#
# the "test" app
#
module WithHelper
  extend Rufus::Sixjo

  get '/hello' do
    "hello #{hello}"
  end

  helpers do
    def hello
      params[:target]
    end
  end
end

class HelpersTest < Test::Unit::TestCase
  include SixjoTestMixin

  def setup
    @app = WithHelper.new_sixjo_rack_app(nil, :environment => 'test')
  end

  def test_0

    assert_equal 200, get('/hello').status
    assert_equal "hello ", @response.body

    assert_equal 200, get('/hello?target=world').status
    assert_equal "hello world", @response.body
  end
end

