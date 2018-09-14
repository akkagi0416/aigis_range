require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/custom_logger'
require 'open-uri'
require 'logger'

class App < Sinatra::Base
  helpers Sinatra::CustomLogger
  
  configure do
    register Sinatra::Reloader
    logger = Logger.new("log/crossdomain_#{settings.environment}.log")
    set :logger, logger
  end

  configure :production do
    enable :reloader
  end


  # for checking (at unicorn)
  get '/' do
    'hello'
  end

  get "/map" do
    logger.info "#{request.ip},#{request.url}"

    # simple check url
    url = params['url'] ? params['url'] : './map/map.jpg'
    if url.match(/png$/i)
      type = :png
    elsif url.match(/(jpg|jpeg)$/i)
      type = :jpg
    else    # not png/jpg
      url  = './map/map.jpg'
      type = :jpg
    end

    # check cache data, and get img data from url if not have cache
    basename = File.basename(url)
    path     = "./map/#{basename}"
    if File.exists?(path)
      is_cached = true
      img_data  = open(path)
    else
      is_cached = false
      img_data  = open(url)
      open(path, 'w'){|f| f.write img_data.read }
    end

    # send data
    headers 'Access-Control-Allow-Origin' => '*'
    headers 'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept'
    headers 'cache' => is_cached.to_s
    send_file(img_data, type: type, disposition: :inline)
  end

end
