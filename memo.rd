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

