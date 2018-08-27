require 'json'

quality = 20  # splite jpg quality

json = JSON.parse(open('icons.json').read)

imgs = []
json.each do |icon|
  imgs << icon['img']
end

system "montage -tile 13x -geometry x72+0+0 -quality #{quality} #{imgs.join(' ')} splite2.jpg"
