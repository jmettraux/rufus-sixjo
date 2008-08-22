
#
# Testing rufus-sixjo
#
# jmettraux at gmail.org
#
# Tue Aug 12 23:36:22 JST 2008
#

require 'test/unit'
require 'testmixins'

#
# the "test" app
#
module PutApp
  extend Rufus::Sixjo

  post '/' do
    #puts request.inspect
    #request.env['rack.input'].read
    request.env['rack.request.form_vars']
  end

  put '/car' do
    #"put : #{request.content || params[:brand]}"
    answer = request.body.read
    answer = params[:brand] if answer.empty?
    answer = request.env['rack.request.form_vars'] if answer.empty?
    "put : #{answer}"
  end

  delete '/car/:id' do
  end
end

class PutTest < Test::Unit::TestCase
  include SixjoTestMixin

  def setup

    @app = PutApp.new_sixjo_rack_app(nil, :environment => 'test')
  end

  def test_0

    #puts post('/', { :input => 'toto' }).body
    assert_equal 200, post('/', { :input => 'toto' }).status
    assert_equal 'toto', @response.body

    assert_equal 200, put('/car', { :input => 'datsun' }).status
    assert_equal 'put : datsun', @response.body

    assert_equal 200, post('/car?_method=put', { :input => 'nissan' }).status
    assert_equal 'put : nissan', @response.body

    assert_equal 404, post('/car', { :input => 'mercedes', :_method => 'put' }).status
    #assert_equal 'put : mercedes', @response.body

    assert_equal 200, delete('/car/fr154147', {}).status
    assert_equal '', @response.body
  end

  def test_1

    assert_equal(
      200,
      post(
        '/car',
        { :input => 'lada', 'X-HTTP-Method-Override' => 'put' }).status)
    assert_equal 'put : lada', @response.body

    assert_equal(
      400,
      post(
        '/car',
        { :input => 'lada', 'X-HTTP-Method-Override' => 'push' }).status)
    assert_equal "unknown HTTP method 'PUSH'", @response.body
  end

  def test_2

    data = {
      "_method" => "put",
      "brand" => "ford"
    }
    form_data = encode_multipart(data)

    assert_equal(
      200,
      post(
        '/car',
        {
          :input => form_data,
          'CONTENT_LENGTH' => form_data.length.to_s,
          'CONTENT_TYPE' => 'multipart/form-data; boundary=AaB03x'
        }).status)
    assert_equal 'put : ford', @response.body
  end

  def test_3

    data = "<brand>mitsubishi</brand>"

    assert_equal(
      200,
      put(
        '/car',
        {
          :input => data,
          'CONTENT_LENGTH' => data.length.to_s,
          'CONTENT_TYPE' => 'application/xml'
        }).status)
    assert_equal "put : #{data}", @response.body
  end
end

