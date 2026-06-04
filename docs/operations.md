# Operations

このドキュメントは、GitHub / PR / CI / deploy / Notion / PDF化 などの運用手順をまとめます。

AIエージェントは差分作成、調査、レビュー補助を行えますが、main反映判断、本番反映判断、秘密情報の扱いは人間が行います。

## 基本方針

- main 直pushは禁止する
- 作業は feature ブランチまたは docs ブランチで行う
- PRで差分、確認結果、レビュー観点を説明する
- CI結果を確認してから merge する
- 本番環境をAIに直接操作させない
- 秘密情報を Issue、PR、README、docs、AIへの指示文に書かない

## featureブランチ作成

作業開始前に main を最新化し、目的に合うブランチを作成します。

```bash
git checkout main
git pull --ff-only origin main
git checkout -b feature/your-topic
```

docs整備のみの場合は、次のような docs ブランチでもよいです。

```bash
git checkout -b docs/your-topic
```

## 差分確認

実装中とPR作成前に差分を確認します。

```bash
git status
git diff --check
git diff --stat
git diff
```

確認すること:

- 目的外のファイルを触っていない
- PHP / React / DB / Docker の変更が意図せず混ざっていない
- `.env` の実値や秘密情報が含まれていない
- Markdownリンクと表示が崩れていない
- テスト未実行の場合は理由を書ける

## PR作成

PR本文は [docs/templates/pr-summary.md](templates/pr-summary.md) を使い、実装前の指示全文を貼るのではなく、実装後レビューに必要な情報だけを書く。

PRに書くこと:

- 変更内容
- 変更理由
- 影響範囲
- 確認内容
- テスト結果
- docs / README / AGENTS.md 更新有無
- 残した判断理由
- レビューしてほしい観点

## CI確認

PR作成後、CIの結果を確認します。

確認すること:

- Laravel test が成功している
- React / TypeScript / Vite build が必要な変更で成功している
- docsのみの変更でアプリテストを省略する場合、PR本文に未実行理由がある
- 失敗時はログを確認し、原因が今回差分か既存要因かを切り分ける

## merge

merge は人間が判断します。

merge前に確認すること:

- PR checklist を満たしている
- レビュー指摘が解消している
- CIが通っている、または未実行理由が妥当である
- 秘密情報が混入していない
- main へ反映してよい差分だけが残っている

## deploy確認

deployが必要な変更では、deploy前に影響範囲を確認します。

確認すること:

- migration の有無
- 環境変数の追加・変更の有無
- Queue / Scheduler / Job への影響
- 外部API呼び出しや quota への影響
- rollback 方針

AIに本番環境へSSH接続させたり、本番 artisan コマンドを実行させたりしません。

## 本番確認

本番確認は人間が行います。

確認すること:

- 対象画面またはAPIが期待通り動く
- ログに秘密情報が出ていない
- Queue / Scheduler が必要な範囲で動いている
- 外部API quota や rate limit に異常がない
- rollback が必要な兆候がない

## Notion更新

Notionは仕様、判断理由、運用メモの共有先として使います。

更新する内容:

- 決定した仕様
- 残した判断理由
- 既知の未対応事項
- レビューや運用で見つかった注意点

書かない内容:

- `.env` の実値
- APIキー
- DBパスワード
- SSH情報
- 本番接続情報

Notion連携処理そのものは、明示的な実装対象になっている場合だけ実装します。

## PDF化

PDF化は、PR説明、仕様メモ、運用メモを配布・保管する必要がある場合に行います。

PDF化前に確認すること:

- 秘密情報が含まれていない
- 実装前の指示全文をそのまま貼っていない
- レビューに必要な情報へ要約されている
- ファイル名と保存先が分かる

PDF生成処理そのものは、明示的な実装対象になっている場合だけ実装します。

## PR用まとめ作成

実装後は [docs/templates/pr-summary.md](templates/pr-summary.md) を使ってPR用まとめを作成します。

docsのみの変更でアプリテストを実行しない場合は、次のように理由を明記します。

```text
テスト結果:
- 未実行
- 理由: docs / AGENTS.md / テンプレートのみの変更で、PHP / React / DB処理に変更がないため
```
