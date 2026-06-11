# UI

このドキュメントは、画面表示、状態表示、レスポンシブ確認の基本方針をまとめます。

UI作成工程の詳細は [ui-development-flow.md](ui-development-flow.md) を参照します。

## 基本方針

- 表示する情報と優先順位を明確にする
- loading / error / empty / selected などの状態を確認する
- mobile / tablet / PC の見え方を確認する
- scroll範囲と固定領域の意図を明確にする
- 操作可能な要素と状態表示を混同しない
- UI契約を PRODUCT へ引き継ぐ

## UI契約の確認

UI契約には、画像だけでなく次の情報を含めます。

- 表示する情報
- 情報の優先順位
- レイアウト
- Field / Card / Button / Modal / Tab などの構造
- loading / error / empty / selected などの状態
- mobile / tablet / PC での見え方
- スクロール範囲
- 画面間導線
- 状態受け渡し
- PRODUCT へ引き継ぐ Component構造
- PRODUCT で置き換える props
- 本データ接続点

MOCK / PROTOTYPE の固定データや検証用ロジックは UI契約ではありません。PRODUCT へ引き継ぐのは、表示構造、props、状態、導線、責務境界です。

## コメントを検討する箇所

- MOCK 由来の UI契約を PRODUCT へ引き継いでいる箇所
- scroll範囲に意図がある箇所
- 表示密度に意図がある箇所
- mobile 専用の操作
- mobile / PC の表示切替
- swipe / autoplay / modal / tab など操作条件が重要な箇所
- PRODUCT で本データへ置き換える境界
- Component へ業務判断を置かないための境界
- 外部ライブラリ都合の例外
- 一見不要に見えるが UX 上必要な余白、配置、z-index、overflow 指定

コメント方針の詳細は [commenting.md](commenting.md) を参照します。
