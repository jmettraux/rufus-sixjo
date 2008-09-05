
#
# Testing rufus-sixjo
#
# jmettraux at gmail.org
#
# Fri Aug  8 15:14:45 JST 2008
#

require 'test/unit'
require 'testmixins'

#
# the "test" app
#
module HeadApp
  extend Rufus::Sixjo

  get '/toto' do
    "toto"
  end
end

class HeadTest < Test::Unit::TestCase
  include SixjoTestMixin

  def setup
    @app = HeadApp.new_sixjo_rack_app(nil, :environment => 'test')
  end

  def test_0

    assert_equal 200, head('/toto').status
    assert_equal '', @response.body
  end
end

