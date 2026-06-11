# Coding Standards

このドキュメントは、実装時の作法、責務境界、TypeScript / React の型方針、CI必須ゲートと手元確認コマンドの区別をまとめます。

## 基本方針

- 既存の設計、命名、ディレクトリ構成に合わせる
- 変更対象ファイルと変更方針を確認してから編集する
- 最小差分で修正する
- 目的外の機能追加、DB変更、Docker構成変更を混ぜない
- 既存PHPを一括formatしない
- CIを通すためにテスト方式を弱めない
- `.env` の実値、APIキー、DBパスワード、AWSキーなどの秘密情報を書かない

## 責務境界

- Controller は HTTP 入口に限定する
- Request は形式バリデーションに限定する
- Action はユースケース手順を扱う
- Service は業務判断、ドメインルール、状態判断を扱う
- Repository は DB 操作や外部データ取得の境界を扱う
- DTO / ListDTO はレイヤー間のデータキャリアとして扱う
- Responder はレスポンスや Inertia props などの出力整形を扱う
- Component は画面表示責務に限定する

責務境界に迷う場合は、実装を進めず人間に確認します。

## PHP

- 型宣言を優先し、PHPDoc はシグネチャだけでは責務や制約が読み取りにくい場合に使う
- DTO / ListDTO に DBアクセス、業務判断、HTTPレスポンス生成、JSONレスポンス生成、View / Inertia / React 用の表示判断を置かない
- Repository には業務判断を置かず、DB操作や外部データ取得の境界に限定する
- Service には HTTP都合や Inertia props の整形を置かない
- Responder は出力整形を担当し、業務判断を持たない

## TypeScript / React

- props型、nullable、empty状態、外部データ由来値は型で明示する
- `any` や型アサーションで不整合を隠さない
- `as unknown as Type` のような二段階アサーションは原則使わない
- 型だけで意味が伝わらない場合は、コメントで業務上の意味や UI契約を補足する
- `as` を使う場合は、理由が必要な箇所ではコメントまたはPR本文に残す
- Component に業務判断、権限判断、本番データ更新を置かない
- 表示用の変換とサーバー側責務を混同しない

UI作業では [ui-development-flow.md](ui-development-flow.md)、[frontend.md](frontend.md)、[ui.md](ui.md) も確認します。

## コメント・アノテーション

コメントは、処理手順をなぞるためではなく、判断理由、責務、制約、UI契約、例外条件、将来壊しやすい境界を説明するために使います。

通常コメント・PHPDoc・JSDoc の詳細は [commenting.md](commenting.md) に従います。

## CI必須ゲート

CI定義を勝手に変更しません。現在の CI 必須ゲートは次の確認です。

- Laravel Pint check
- frontend build
- Laravel tests
- Vitest

`composer format-check` は `pint --test` を実行する前提です。CIを通す目的で `pint --test --dirty` に弱めません。

## 手元確認コマンド

変更内容に応じて、必要な確認コマンドを選びます。

docsのみの変更:

```bash
git diff --check
```

Laravel / PHP 変更:

```bash
docker compose run --rm artisan test
```

React / TypeScript / TSX / Vite 変更:

```bash
docker compose run --rm npm npm run build
docker compose run --rm npm npm run test:run
```

TypeScript / TSX 変更時は、必要に応じて次も手元確認として実行します。

```bash
docker compose run --rm npm npm run typecheck
```

`npm run typecheck` は削除しません。ただし、既存の型エラーが残っている間は CI 必須ゲートに戻しません。typecheck を CI 必須にする判断は、既存型エラーを別PRで解消してから行います。
