## 射程ツール

アイギスの射程が確認できるツール。

* 射程エリアをマウスで拡大・縮小・移動
* 射程エリアを複数作成できるし削除も可能
* mapは選択とドラッグドロップに対応

今後

* アイコンで配置図も作れる


## メモ


### p5.jsの導入

map画像に射程を描画するために[p5.js](https://p5js.org/)を導入。
p5.jsは[YouTube](https://www.youtube.com/user/shiffman/playlists?view=50&shelf_id=14)がとても参考になります。

p5.jsは手軽に直線や円などの図形描画ができるので、
射程エリアをmapに重ねて目的の射程ツールの作成にぴったりです。
ドラッグドロップも[example](https://p5js.org/examples/dom-drop.html)が参考になります。

これだけで簡易的な射程確認ツールが作れます。


### map選択

ストーリーや魔人のmapを選べるようにします。
mapは増減するのでjsonなどから読み込んで選択できるようにするのが望ましいです。

最初はp5.jsでjsonを読み込んでhtml表示をしました。
layoutとp5.jsのoperationを分けた方が見通しがよいと考えてvue.jsを導入します。


### Cross-Domain問題

Wikiのmapデータを利用して発生しました。
例えばgyazoドメインは次のようにgyazoアクセスのみアクセス許可があります。

```
access-control-allow-origin: https://gyazo.com
```

このため、p5.jsでloadImage(url)するとCross-Domainではじかれて画像が読み込めません。
テストデータのakkagi.infoの画像はcrossドメイン許可だったのでこの問題が未検出でした。

```
access-control-allow-origin: *
```

対策

1. ローカルにmapデータを保存
2. 自前api経由で間接的にmapデータを取得
3. imgやbackgroundに画像を表示

各デメリット

1はデメリットとして、mapをローカルに保存する手間がかかります。
2はapiを動作させる手間がかかります。
3はsaveにp5.jsとは別のアプローチが必要です。

3のアプローチでcanvasのbackgroundに画像を表示させると
p5.jsの挙動がおかしくなり(画像サイズの半分しかclearが反応しない)、
saveCanvasではimgやbackgroundの画像は取得できないので検討中止します。

2はsinatraで取得できることを確認しました。
ただ、サーバーで画像取得->ローカルへ転送というリソース消費と
sinatraを起動しつづけることとpathやプロセス管理の手間で検討中止します。

```
require 'sinatra'
require 'open-uri'

get "/map" do
  headers 'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept'
  headers 'Access-Control-Allow-Origin' => '*'

  send_file(open(params['url']), type: 'image/jpeg', disposition: 'inline')
end
```

map登録に合わせてmap保存の手間がかかりますが
1のやり方がシステムが簡単なので採用します。

と思ったけど、1mapで1MB以上あってデータ容量が大きいので
やっぱり2の中継apiで進めてみます。


