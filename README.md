# kiriban

ニコニコ動画のタグレポからキリ番通知を収集して jsonファイルにするスクリプトです。

手抜きです。

## 準備
- 以下をインストール
    - [git for windows](https://gitforwindows.org/)
    - [jq](https://stedolan.github.io/jq/)

## 実行方法
- タグを引数にして kiriban.sh を実行する。
- `./kiriban.sh factorio`
- `factorio.json` が生成される。

## 結果
こんなかんじ

```json
{
  "tag": "factorio",
  "kiriban": [
    {
      "date": "2020-07-22T06:06:20.630+09:00",
      "video": {
        "id": "sm33532839",
        "title": "Factorioゆっくり解説プレイ 02 - スループットと精錬場"
      },
      "viewCount": 10000
    },
    {
      "date": "2020-07-19T10:11:54.249+09:00",
      "video": {
        "id": "sm28466408",
        "title": "【Factorio】姉妹で遊ぶ工場建築ゲー 後編【VOICEROID実況】"
      },
      "viewCount": 100000
    }
  ],
  "foundSince": "2020-07-12T17:51:03+09:00"
}
```

## カスタマイズ
- kiriban.sh の `max_pages` を増やすと最大探索ページ数が増えます。増やしすぎるとサーバー攻撃になるので注意
- kirban.sh の `days` を増やすと過去 days 日分取得できたら停止します。

## License
- GPLv3

## Author
@koizuka
