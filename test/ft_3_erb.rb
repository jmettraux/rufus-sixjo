
#
# Testing rufus-sixjo
#
# jmettraux at gmail.org
#
# Mon Aug 11 19:09:58 JST 2008
#

require 'test/unit'
require 'fileutils'
require 'testmixins'

#
# the "test" app
#
module ErbApp
  extend Rufus::Sixjo

  get '/' do
    erb 'view0'
  end

  get '/good' do
    erb 'view0', :locals => { :life => 'good' }
  end

  get '/good2' do
    erb :view0, :whatever => true, :locals => { :life => 'good' }
  end

  get '/reckless' do
    erb :view1
  end

  get '/good3' do
    erb :view0, :whatever => true, :locals => { :life => nil }
  end

  get '/nested' do
    erb :nested0
  end
end

class ErbTest < Test::Unit::TestCase
  include SixjoTestMixin

  def setup

    @app = ErbApp.new_sixjo_rack_app(nil, :environment => 'test')

    save_view('views/view0.erb', 'this is view0, life is <%= life %>')
    save_view('views/view1.erb', '<%= request.path_info %>')
    save_view('views/nested/nested0.erb', 'this is nested0, obviously')
  end

  def test_0

    assert_equal 500, get('/').status

    assert_equal 200, get('/good').status
    assert_equal 'this is view0, life is good', @response.body

    assert_equal 200, get('/good2').status
    assert_equal 'this is view0, life is good', @response.body

    assert_equal 200, get('/reckless').status
    assert_equal '/reckless', @response.body.strip
  end

  def test_1

    assert_equal 200, get('/good3').status
    assert_equal 'this is view0, life is ', @response.body
  end

  def test_2

    assert_equal 500, get('/nested').status

    old_view_path = Rufus::Sixjo.view_path
    Rufus::Sixjo.view_path = 'views/nested'

    assert_equal 200, get('/nested').status
    assert_equal 'this is nested0, obviously', @response.body

    Rufus::Sixjo.view_path = old_view_path
  end
end

