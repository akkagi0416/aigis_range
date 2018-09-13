require 'sinatra'
require 'open-uri'

get "/map" do
  url = params['url'] ? params['url'] : './map/map.jpg'
  if url.match(/png$/i)
    type = :png
  elsif url.match(/jpg$/i)
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

  headers 'Access-Control-Allow-Origin' => '*'
  headers 'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept'
  headers 'cache' => is_cached
  send_file(img_data, type: type, disposition: :inline)
end
