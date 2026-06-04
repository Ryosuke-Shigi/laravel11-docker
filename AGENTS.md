# AGENTS.md

このファイルは、AIエージェントが最初に読むための薄い入口です。
詳細な設計方針、DTO運用、テスト、PR、セキュリティ方針は `docs/` を参照してください。

## 基本方針

このリポジトリでは、AIを丸投げ実装者として扱いません。

仕様確定、責務境界、テスト観点、完成判定、本番反映判断は人間が行い、AIは実装補助、調査、差分修正、レビュー補助として使います。

## 作業前に読むドキュメント

- [README.md](README.md): アプリ概要、起動手順、テスト手順、PR運用の概要
- [docs/architecture.md](docs/architecture.md): ADRパターンとレイヤードアーキテクチャ
- [docs/dto.md](docs/dto.md): DTO / ListDTO の設計方針
- [docs/testing.md](docs/testing.md): TDDとテスト境界
- [docs/logging.md](docs/logging.md): ログ分類と記録してよい情報
- [docs/development-flow.md](docs/development-flow.md): 仕様整理からPRまでの流れ
- [docs/operations.md](docs/operations.md): GitHub / PR / CI / deploy などの運用手順
- [docs/setup.md](docs/setup.md): 初期構築とローカル確認手順
- [docs/pr-checklist.md](docs/pr-checklist.md): PR前チェックリスト
- [docs/security.md](docs/security.md): 秘密情報と本番環境の扱い
- [docs/templates/instruction-summary.md](docs/templates/instruction-summary.md): 実装前の指示用まとめテンプレート
- [docs/templates/pr-summary.md](docs/templates/pr-summary.md): PR本文用まとめテンプレート

## 責務境界

- Controller は HTTP 入口に限定する
- Request は形式バリデーションに限定する
- Action はユースケース手順を扱う
- Service は業務判断、ドメインルール、状態判断を扱う
- Repository は DB 操作や外部データ取得の境界を扱う
- DTO / ListDTO はレイヤー間のデータキャリアとして扱う
- Responder はレスポンスや Inertia props などの出力整形を扱う
- Component は画面表示責務に限定する

## DTOで禁止すること

DTO / ListDTO に次の責務を持たせないでください。

- DBアクセス
- 業務判断
- HTTPレスポンス生成
- JSONレスポンス生成
- View / Inertia / React 用の表示判断

## 作業ルール

- 変更対象ファイルと変更方針を確認してから編集する
- 最小差分で修正する
- 目的外のアプリ機能追加、DB変更、Docker構成変更をしない
- `.env` の実値、APIキー、DBパスワード、AWSキーなどの秘密情報を書かない
- 変更後は差分を確認する
- テストが必要な変更では、既存のテスト方針に従って確認する
- 指定範囲外の代替実装へ進まない
- 責務境界、秘密情報、本番操作、仕様判断で迷う場合は作業を止めて人間に確認する

今回のような docs のみの変更では、アプリテスト実行は必須ではありません。ただし、リンク切れ、Markdownの表示崩れ、目的外のコード変更がないことは確認してください。
