# Root Repository Rules

- Status: active
- Scope: outer Docker / environment repository
- Source: root `AGENTS.md` から詳細ルールを退避

## 基本方針

このリポジトリでは、AIを丸投げ実装者として扱いません。

仕様確定、責務境界、テスト観点、完成判定、本番反映判断は人間が行い、AIは実装補助、調査、差分修正、レビュー補助として使います。

## 作業ディレクトリ前提

このリポジトリでは、Laravelアプリケーション本体は `/src` 配下にあります。

- Laravel / PHP / artisan / app / routes / database / tests / resources を触る作業は、必ず `/src` を基準に確認する
- `php artisan`、`composer`、`npm`、`tests`、`routes`、`app`、`database` を扱う場合は `/src` 側のファイルを対象にする
- リポジトリ直下は Docker / Makefile / infra 系の管理領域として扱う
- 指示に「Laravel側」「src側」「アプリ側」とある場合は `/src` を作業ルートとする
- `/src` 外に Laravel 用の `app/`、`routes/`、`database/`、`resources/` を新規作成しない
- 判断に迷う場合は、作業前に `pwd` と `ls` で現在位置を確認してから進める

## src 側 AGENTS.md の参照ルール

このリポジトリの root は Docker / nginx / php-fpm / mysql / redis / npm / queue / scheduler などの外側構成を扱います。

Laravel アプリ本体は `src/` 配下にあり、別Gitリポジトリとして扱います。

次の作業を行う場合は、root の `AGENTS.md` だけで判断せず、作業前に必ず `src/AGENTS.md` を読みます。

- `app/`
- `routes/`
- `resources/`
- `database/`
- `config/`
- `tests/`
- `public/`
- `artisan`
- `composer.json`
- `package.json`
- `vite.config.*`
- `phpunit.xml`
- Laravel / React / Inertia / TypeScript の画面・機能修正

Docker 構成だけを変更する場合は、root 側の `AGENTS.md` とこの文書を正本とします。

Docker 構成と Laravel アプリ本体の両方に関わる場合は、root の `AGENTS.md`、この文書、`src/AGENTS.md` のすべてを読みます。

root 側の `git status` / `git pull` が最新でも、`src/` 側が最新とは限りません。
Laravel / React 本体の確認・修正・反映では、必ず `src/` 側の状態も確認します。

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
- Laravel / React / TypeScript 側のコメント詳細ルールは、作業前に `src/AGENTS.md` で確認する
- コメントで処理変更や責務違反を正当化しない

## 作業ルール

- 変更対象ファイルと変更方針を確認してから編集する
- 最小差分で修正する
- 目的外のアプリ機能追加、DB変更、Docker構成変更をしない
- `.env` の実値、APIキー、DBパスワード、AWSキーなどの秘密情報を書かない
- 変更後は差分を確認する
- テストが必要な変更では、既存のテスト方針に従って確認する
- 指定範囲外の代替実装へ進まない
- 責務境界、秘密情報、本番操作、仕様判断で迷う場合は作業を止めて人間に確認する
