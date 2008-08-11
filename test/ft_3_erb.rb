
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
end

class ErbTest < Test::Unit::TestCase
  include SixjoTestMixin

  def setup

    @app = ErbApp.new_rack_application(nil)

    fn = 'views/view0.erb'

    FileUtils.mkdir('views') unless File.exist?('views')
    FileUtils.rm(fn) if File.exist?(fn)
    File.open(fn, 'w') { |f| f.write "this is view0, life is <%= life %>" }
  end

  def test_0

    assert_equal 200, get('/').status
    assert_equal 'this is view0, life is', @response.body.strip

    assert_equal 200, get('/good').status
    assert_equal 'this is view0, life is good', @response.body.strip
  end
end

