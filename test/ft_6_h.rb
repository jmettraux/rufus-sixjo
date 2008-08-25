
#
# Testing rufus-sixjo
#
# jmettraux at gmail.org
#
# Mon Aug 25 09:09:34 JST 2008
#

require 'test/unit'
require 'testmixins'

#
# the "test" app
#
module HachiHelper
  extend Rufus::Sixjo

  get '/hello' do
    hello
  end

  get '/bundi' do
    h('<bundi>')
  end

  get '/bondzoi' do
    erb :ft6, :locals => { :life => '>good<' }
  end

  helpers do
    def hello
      h("hello #{params[:target]}")
    end
  end
end

class HachiTest < Test::Unit::TestCase
  include SixjoTestMixin

  def setup

    @app = HachiHelper.new_sixjo_rack_app(nil, :environment => 'test')

    save_view('views/ft6.erb', 'ft6, life is <%= h(life) %>')
  end

  def test_0

    assert_equal 200, get('/hello?target=maam').status
    assert_equal 'hello maam', @response.body

    assert_equal 200, get('/bundi').status
    assert_equal '&lt;bundi&gt;', @response.body
  end

  def test_1

    assert_equal 200, get('/bondzoi').status
    assert_equal 'ft6, life is &gt;good&lt;', @response.body
  end
end

