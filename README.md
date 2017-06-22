# SLRequest
## 概要
`SLRequest`は、TwitterやFacebookなどを利用するためにユーザのSNSのアカウント情報を取得したり、<br>SNSに投稿するためのHTTPリクエストをするクラスです。

## 関連クラス
NSObject
　
## 実装手順
1. 端末に登録されているユーザのSNSのアカウント情報を取得します。
2. アカウント情報、SNSに投稿する文字列、画像情報をパラメータにセットしてHTTPリクエストを送信します。

## イニシャライザ

|イニシャライザ|説明|サンプル|
|---|---|---|
|`init(forServiceType:requestMethod:url:parameters:)`| リクエストオブジェクトを生成する| `SLRequest.init(forServiceType: SLServiceTypeTwitter,`<br>` requestMethod: .POST, url: requestUrl,`<br>` parameters: params)` |

## 主要プロパティ

|プロパティ名|説明|サンプル|
|---|---|---|
|`account` | リクエストを認証するために使用するアカウント情報 | `slRequest.account` |
| `requestMethod` | リクエストに使用するメソッド | `slRequest.requestMethod` |
| `url` | リクエストの宛先URL | `slRequest.url` |
|`var parameters: [AnyHashable : Any]! { get }` | リクエストのパラメータ | `slRequest.parameters` |

## 主要メソッド

|メソッド名|説明|サンプル|
|---|---|---|
|`addMultipartData`<br>`(_:withName:type:filename:)` | リクエストの`body`にデータを追加する | `slRequest.addMultipartData`<br>`(UIImageJPEGRepresentation(image, 1.0),`<br>`withName: "media",`<br>`type: "image/jpeg",`<br>`filename: "image.jpeg")` |
| `perform(handler:)` | 非同期要求を実行し、<br>完了したら指定ハンドラを呼び出す| `slRequest.perform(handler: { (data, urlResponse, error) in`<br>`DispatchQueue.global(qos: .default).async {`<br>`completion(error)`<br>`    }    `<br>`})` |

## フレームワーク
Social.framework

## サポートOSバージョン
iOS6.0以上

## 開発環境
|category | Version|
|---|---|
| Swift | 3.0.2 |
| XCode | 8.2.1 |
| iOS | 10.0〜 |

## 参考
https://developer.apple.com/reference/social/slrequest
