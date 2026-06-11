# AGENTS.md

このファイルは、AIエージェントが最初に読むための薄い入口です。
詳細な設計方針、DTO運用、テスト、PR、セキュリティ方針は `docs/` を参照してください。
作業開始時は [docs/index.md](docs/index.md) を確認し、作業内容に応じて必要な docs だけを参照します。

## 基本方針

このリポジトリでは、AIを丸投げ実装者として扱いません。

仕様確定、責務境界、テスト観点、完成判定、本番反映判断は人間が行い、AIは実装補助、調査、差分修正、レビュー補助として使います。

## 作業ディレクトリ前提

このリポジトリでは、Laravelアプリケーション本体は `/src` 配下にある。

- Laravel / PHP / artisan / app / routes / database / tests / resources を触る作業は、必ず `/src` を基準に確認する
- `php artisan`、`composer`、`npm`、`tests`、`routes`、`app`、`database` を扱う場合は `/src` 側のファイルを対象にする
- リポジトリ直下は Docker / Makefile / README / infra 系の管理領域として扱う
- 指示に「Laravel側」「src側」「アプリ側」とある場合は `/src` を作業ルートとする
- `/src` 外に Laravel 用の `app/`、`routes/`、`database/`、`resources/` を新規作成しない
- 判断に迷う場合は、作業前に `pwd` と `ls` で現在位置を確認してから進める

## 参照ドキュメント

- [README.md](README.md): アプリ概要、起動手順、テスト手順、PR運用の概要
- [docs/index.md](docs/index.md): docs全体の目次と作業別の参照先
- [docs/architecture.md](docs/architecture.md): Laravel / ADR / レイヤードアーキテクチャの責務境界
- [docs/dto.md](docs/dto.md): DTO / ListDTO の設計方針
- [docs/testing.md](docs/testing.md): テスト方針・TDD・確認コマンド
- [docs/logging.md](docs/logging.md): ログ方針、ログ分類、記録してよい情報
- [docs/commenting.md](docs/commenting.md): 通常コメント・PHPDoc・JSDocの運用方針
- [docs/development-flow.md](docs/development-flow.md): 仕様整理からPRまでの流れ
- [docs/ui-development-flow.md](docs/ui-development-flow.md): MOCK / PROTOTYPE / PRODUCT のUI作成工程
- [docs/coding-standards.md](docs/coding-standards.md): 実装作法、型、CI必須ゲートと手元確認コマンド
- [docs/frontend.md](docs/frontend.md): React / TypeScript / Inertia のフロントエンド方針
- [docs/ui.md](docs/ui.md): UI設計、状態表示、レスポンシブ確認の方針
- [docs/operations.md](docs/operations.md): GitHub / PR / deploy / 本番確認 / Notion / PDF化などの運用手順
- [docs/setup.md](docs/setup.md): 初期構築・Docker・.env.example・migrate・npm
- [docs/pr-checklist.md](docs/pr-checklist.md): PR前チェックリスト
- [docs/security.md](docs/security.md): 秘密情報と本番環境の扱い
- [docs/templates/instruction-summary.md](docs/templates/instruction-summary.md): 指示用まとめの型
- [docs/templates/pr-summary.md](docs/templates/pr-summary.md): PR用まとめの型

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

## コメント方針

- 通常コメント・PHPDoc・JSDocは、必要な箇所に日本語で残す
- コメントの詳細ルールは [docs/commenting.md](docs/commenting.md) に従う
- コメントで処理変更や責務違反を正当化しない
- UI作業で MOCK 由来の UI契約を引き継ぐ場合は、必要に応じてコメントや型で境界を補足する

## UI作業

- UI作業では [docs/ui-development-flow.md](docs/ui-development-flow.md) を確認する
- MOCKで画面を1つずつ作り、PROTOTYPEで全体構成と導線を確認し、PRODUCTでUI契約を本データと責務分離へ接続する
- PRODUCTで見た目を再発明せず、MOCK / PROTOTYPE の Component構造、props、状態、導線を確認して移植する
- MOCK / PROTOTYPE の固定データや検証用ロジックは本番へ引き継がない

## 作業ルール

- 変更対象ファイルと変更方針を確認してから編集する
- 最小差分で修正する
- 目的外のアプリ機能追加、DB変更、Docker構成変更をしない
- `.env` の実値、APIキー、DBパスワード、AWSキーなどの秘密情報を書かない
- 変更後は差分を確認する
- テストや確認コマンドは作業内容に応じて選ぶ
- TypeScript / TSX を変更した場合は、必要に応じて手元確認として `npm run typecheck` を扱う
- `npm run typecheck` は現時点では CI 必須ゲートではない
- 指定範囲外の代替実装へ進まない
- 責務境界、秘密情報、本番操作、仕様判断で迷う場合は作業を止めて人間に確認する
- main へ直接作業・push しない
- commit / push はユーザーの明示指示がある場合に行う
- merge は人間の明示判断を受けてから行う
