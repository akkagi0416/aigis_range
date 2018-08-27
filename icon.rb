require 'nokogiri'
require 'json'
require 'pp'

#
# 人気投票のアイコンデータをicon.jsonにまとめる
#

altema = 'altema.html'
hosoku = 'hosoku.csv'   # altemで判別できないrare
groups = ['vote/group_a.html', 'vote/group_b.html', 'vote/group_c.html']
rares  = ['アイアン', 'ブロンズ', 'シルバー', 'ゴールド', 'サファイア', 'プラチナ', 'ブラック']

class Icon
  attr_accessor :name, :long_name, :img, :rare
  def initialize(long_name, img)
    @long_name = long_name
    m = long_name.match(/([\p{katakana}|ー]{2,})$/)
    if m.nil?
      @name = long_name
    else
      @name = m[1]
    end
    @img       = img
    @rare      = nil
  end
end

icons = []

# collect icon data
groups.each do |group|
  doc = Nokogiri::HTML(open(group))
  # 1 - 10
  doc.css('.element').each do |div|
    long_name = div.inner_html.match(/<br>(.*?)<br>/)[1]
    img  = div.css('img').attr('src').value
    rare = nil
    icons << Icon.new(long_name, img)
  end

  # 11 -
  doc.css('ul li').each do |li|
    long_name = li.css('c2').text
    img  = li.css('img').attr('src').value
    rare = nil
    icons << Icon.new(long_name, img)
  end
end

# get rare from using [altema.html](https://altema.jp/sennenaigis/charalist)
doc = Nokogiri::HTML(open(altema))
doc.css('.alldata table tbody tr').each do |tr|
  name = tr.css('td:nth-of-type(1)').text
  rare = tr.css('td:nth-of-type(2)').text
  icon = icons.select{|i| i.name == name }  # TODO: all search -> efficient search
  next if icon.empty?
  icon[0].rare = rare
end

# hosoku for informing icon of rare == nil
open(hosoku).each_line do |line|
  long_name, rare = line.chomp.split(',')
  icon = icons.select{|i| i.long_name == long_name }  # TODO: all search -> efficient search
  icon[0].rare = rare
end

# sort : rare => name
icons_sorted = []
rares.reverse.each do |rare|
  icons_rare = icons.select{|i| i.rare == rare }.sort{|a, b| a.name <=> b.name }
  icons_sorted.concat(icons_rare)
end


json = JSON.pretty_generate(
  icons_sorted.map do |icon|
    {
      "long_name" => icon.long_name,
      "name"      => icon.name,
      "img"       => icon.img.sub(/group_[abc]_files/, 'icon'),
      "rare"      => icon.rare
    }
  end
)

open('aiu.json', 'w'){|f| f.write json }
