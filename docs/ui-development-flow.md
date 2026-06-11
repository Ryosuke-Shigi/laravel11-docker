# UI Development Flow

このドキュメントは、MOCK / PROTOTYPE / PRODUCT の UI 作成工程を分け、MOCK で確認した UI契約を PRODUCT へ安全に引き継ぐための方針をまとめます。

UIは画像比較だけで再現するものではありません。Component構造、props、状態、導線、責務境界を含む UI契約を確認し、PRODUCT では見た目を再発明せず、本データと責務分離へ接続します。

## MOCK

MOCK は、画面を1つずつ作る段階です。

目的:

- 固定データで UI 構造を確認する
- 表示する情報と優先順位を確認する
- loading / error / empty / selected などの状態表示を確認する
- mobile / tablet / PC の見え方を確認する
- scroll構造や操作感を確認する
- 画面単体の UI契約を作る

扱ってよいもの:

- Card / Button / Field / Modal / Tab / Navigation
- loading / error / empty / selected などの表示状態
- mobile / tablet / PC 表示
- scroll範囲
- 背景エフェクト
- 固定データ

扱わないもの:

- 本番API通信
- 本番DB保存
- 業務判断
- 権限判断
- 正式な状態遷移
- 本番 Action / Service / Repository

## PROTOTYPE

PROTOTYPE は、MOCK で作った画面同士をつなぐ段階です。

目的:

- 全体の構成を確認する
- 画面間のつながりを確認する
- 画面遷移を確認する
- 状態受け渡しを確認する
- 簡易的なデータの流れを確認する

扱ってよいもの:

- MOCK と同じ UI
- Common Component
- 固定データや検証用データ
- 簡易通信
- 検証用 Route / Controller
- 画面遷移
- 操作フロー

扱わないもの:

- 本番業務ロジック
- 正式なDB設計
- 本番データ更新
- 本番APIへの変更操作
- PRODUCT と同等の完成判定

## PRODUCT

PRODUCT は、MOCK / PROTOTYPE で確認した UI契約を引き継ぎ、本実装へ接続する段階です。

目的:

- UIをゼロから作り直さない
- MOCK の UI契約を壊さない
- PROTOTYPE の導線を引き継ぐ
- 本データへ接続する
- Action / Service / Repository / DTO / Responder / Component / Test へ接続する

やること:

- MOCK / PROTOTYPE の Component構造を確認する
- 必要に応じてコードを複製・移動する
- PRODUCT 側の配置へ移す
- 固定データを本データへ置き換える
- props を Responder 経由にする
- 業務判断を Component へ置かない
- 必要なテストを追加する

やらないこと:

- PRODUCT で見た目を再発明する
- 画像だけを見て UI を再実装する
- MOCK / PROTOTYPE の固定データや検証用ロジックを本番へ引き継ぐ
- Component に業務判断や権限判断を置く

## UI契約

UI契約とは、MOCK / PROTOTYPE で確認した、PRODUCT へ引き継ぐべき画面上の約束です。

UI契約に含めるもの:

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

UI契約に含めないもの:

- MOCK / PROTOTYPE の固定データ
- 検証用の簡易ロジック
- 本番業務判断の代替
- 一時的な Route / Controller の都合

## PRODUCT移植時の確認

PRODUCT へ進む前に、次を確認します。

- 引き継ぐ Component と捨てる検証用処理が分かれている
- props の形と nullable / empty 状態が明確になっている
- UI状態と業務状態の境界が分かれている
- 本データ接続点が Responder / DTO / Action 側に寄せられている
- Component が表示責務に限定されている
- 必要な Feature / Unit / Vitest の確認観点が整理されている

## コメント・アノテーション

MOCK 由来の UI契約、scroll範囲、表示密度、mobile / PC の切り替え、swipe / autoplay / modal / tab など操作条件が重要な箇所では、コメントや型アノテーションで意図を補います。

コメントは処理手順の逐語説明ではなく、判断理由、責務、制約、UI契約、例外条件、将来壊しやすい境界を説明するために使います。詳細は [commenting.md](commenting.md) と [coding-standards.md](coding-standards.md) を参照します。
