
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
module Simple
  extend Rufus::Sixjo

  get '/toto' do
    'toto'
  end

  get '/toto/:id' do
    "toto with id #{params[:id]} .#{request.env['_FORMAT']}"
  end

  #get '/(momo|dodo)/:id' do
  #  "modo with id #{params[:id]}"
  #end
end

class SimpleTest < Test::Unit::TestCase
  include SixjoTestMixin

  def setup
    @app = Simple.new_sixjo_rack_app(nil, :environment => 'test')
  end

  def test_0

    assert_equal 404, get('/nada').status

    assert_equal 200, get('/toto').status
    assert_equal 'toto', @response.body

    assert_equal 200, get('/toto/3').status
    assert_equal 'toto with id 3 .', @response.body

    assert_equal 200, get('/toto/3.json').status
    assert_equal 'toto with id 3 .json', @response.body

    assert_equal 200, get('/toto/3.json?q=nada').status
    assert_equal 'toto with id 3 .json', @response.body
  end

  #def test_1
  #  assert_equal 200, get('/momo/2').status
  #  assert_equal 'modo with id 2', @response.body
  #end
end

