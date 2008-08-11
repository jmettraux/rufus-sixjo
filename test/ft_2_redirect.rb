
#
# Testing rufus-sixjo
#
# jmettraux at gmail.org
#
# Mon Aug 11 17:23:23 JST 2008
#

require 'test/unit'
require 'testmixins'

#
# the "test" app
#
module RedirectApp
  extend Rufus::Sixjo

  get '/' do
    redirect '/elsewhere'
  end
end

class RedirectTest < Test::Unit::TestCase
  include SixjoTestMixin

  def setup
    @app = RedirectApp.new_rack_application(nil)
  end

  def test_0
    assert_equal 303, get('/').status
    assert_equal '/elsewhere', @response.location
    assert_equal "303 redirecting to /elsewhere", @response.body
  end
end

