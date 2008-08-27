
#
# Testing rufus-sixjo
#
# jmettraux at gmail.org
#
# Wed Aug 27 11:12:17 JST 2008
#

require 'test/unit'
require 'testmixins'

NOW = Time.now

#
# the "test" app
#
module EtagApp
  extend Rufus::Sixjo

  get '/hello' do
    set_etag('wienerli')
    'hello'
  end

  get '/sayonara' do
    set_last_modified(NOW)
    'sayonara'
  end
end

class EtagTest < Test::Unit::TestCase
  include SixjoTestMixin

  def setup

    @app = EtagApp.new_sixjo_rack_app(nil, :environment => 'test')
  end

  def test_0_etag

    assert_equal 200, get('/hello').status
    assert_equal '"wienerli"', @response.headers['ETag']
    assert_equal 'hello', @response.body

    assert_equal 304, get('/hello', 'HTTP_IF_NONE_MATCH' => '"wienerli"').status
    assert_equal '"wienerli"', @response.headers['ETag']
    assert_equal '', @response.body
  end

  def test_1_last_modified

    assert_equal 200, get('/sayonara').status
    assert_not_nil @response.headers['Last-Modified']
    assert_equal 'sayonara', @response.body

    get(
      '/sayonara',
      'HTTP_IF_MODIFIED_SINCE' => @response.headers['Last-Modified'])
    assert_equal 304, @response.status
    assert_equal '', @response.body

    assert_equal(
      200,
      get(
        '/sayonara',
        'HTTP_IF_MODIFIED_SINCE' => (Time.now - 3601).httpdate
      ).status)
  end

end

