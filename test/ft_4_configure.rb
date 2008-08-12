
#
# Testing rufus-sixjo
#
# jmettraux at gmail.org
#
# Tue Aug 12 13:38:16 JST 2008
#

require 'test/unit'
require 'testmixins'

#
# the "test" app
#
module ConfigureApp
  extend Rufus::Sixjo

  configure do
    $apple = 'pomme'
    @pear = 'poire'
  end

  configure :production, :development do
    $peach = 'pe^che'
  end

  get '/' do
    "apple is #{$apple}"
  end

  get '/pear' do
    "pear is #{application.instance_variable_get(:@pear)}"
  end

  get '/peach' do
    "peach is #{$peach}"
  end
end

class ConfigureTest < Test::Unit::TestCase
  include SixjoTestMixin

  def setup

    @app = ConfigureApp.new_sixjo_rack_app(nil, :environment => 'test')
  end

  def test_0

    assert_equal 200, get('/').status
    assert_equal 'apple is pomme', @response.body.strip

    assert_equal 200, get('/pear').status
    assert_equal 'pear is poire', @response.body.strip

    assert_equal 200, get('/peach').status
    assert_equal 'peach is', @response.body.strip
  end
end

