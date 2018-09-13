ENV['RACK_ENV'] = 'test'

require './crossdomain.rb'
require 'minitest/autorun'
require 'rack/test'
require 'fileutils'

class CrossDomain < Minitest::Test
  include Rack::Test::Methods


  def app
    Sinatra::Application
  end

  def setup
    @map = 'map/48fb96d871d246c2dd521e3926b124a6.png' # from https://i.gyazo.com/48fb96d871d246c2dd521e3926b124a6.png
    FileUtils.rm(@map) if File.exists?(@map)
  end

  def teardown
    FileUtils.rm(@map) if File.exists?(@map)
  end
 
  def test_map_without_url
    get '/map'
    assert last_response.ok?
    # {"Content-Type"=>"image/jpeg", "Access-Control-Allow-Origin"=>"*", "Access-Control-Allow-Headers"=>"Origin, X-Requested-With, Content-Type, Accept", "Content-Disposition"=>"inline; filename=\"map.jpg\"", "Last-Modified"=>"Thu, 13 Sep 2018 00:56:27 GMT", "Content-Length"=>"1226414", "X-Content-Type-Options"=>"nosniff"}
    assert_equal 'image/jpeg',  last_response.header['Content-Type']
    assert_equal '*',           last_response.header['Access-Control-Allow-Origin']
    assert_equal '1226414',     last_response.header['Content-Length']
    assert_equal 'inline; filename="map.jpg"',   last_response.header['Content-Disposition']
    assert_equal true,        last_response.header['cache']
  end

  def test_map_without_url_direct_url # direct url
    get '/map/map.jpg'  # public/map/map.jpg
    assert last_response.ok?
    assert_equal '1226414',     last_response.header['Content-Length']
  end

  def test_map_without_url_not_exist
    get '/map/map_.jpg'  # public/map/map.jpg
    refute last_response.ok?
  end

  def test_map_with_url_local
    get '/map?url=map/map.jpg'
    assert last_response.ok?
    assert_equal '1226414', last_response.header['Content-Length']
  end

  def test_map_with_url
    refute File.exist?(@map)
    get '/map?url=https://i.gyazo.com/48fb96d871d246c2dd521e3926b124a6.png'
    assert_equal 'image/png', last_response.header['Content-Type']
    assert_equal '*',         last_response.header['Access-Control-Allow-Origin']
    assert_equal false,     last_response.header['cache']
    assert_equal '951528',    last_response.header['Content-Length']
    assert File.exist?(@map)

    # 2nd times(check using cache)
    get '/map?url=https://i.gyazo.com/48fb96d871d246c2dd521e3926b124a6.png'
    assert_equal 'image/png', last_response.header['Content-Type']
    assert_equal '*',         last_response.header['Access-Control-Allow-Origin']
    assert_equal true,      last_response.header['cache']
    assert_equal '951528',    last_response.header['Content-Length']
  end
end
