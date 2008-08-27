
#
# Testing rufus-sixjo
#
# jmettraux at gmail.org
#
# Wed Aug 27 11:12:17 JST 2008
#

require 'test/unit'
require 'testmixins'

#
# the "test" app
#
module EtagApp
  extend Rufus::Sixjo

  get '/hello' do
    set_etag('wienerli')
    'hello'
  end
end

class EtagTest < Test::Unit::TestCase
  include SixjoTestMixin

  def setup

    @app = EtagApp.new_sixjo_rack_app(nil, :environment => 'test')
  end

  def test_0

    assert_equal 200, get('/hello').status
    assert_equal '"wienerli"', @response.headers['ETag']
    assert_equal 'hello', @response.body

    assert_equal 304, get('/hello', 'HTTP_IF_NONE_MATCH' => '"wienerli"').status
    assert_equal '"wienerli"', @response.headers['ETag']
    assert_equal '', @response.body
  end

end

