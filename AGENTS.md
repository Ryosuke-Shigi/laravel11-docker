# AGENTS.md

このファイルは、AIエージェントが最初に読むための root 側入口です。

root は Docker / nginx / php-fpm / mysql / redis / npm / queue / scheduler などの外側構成を扱い、Laravel アプリ本体は `src/` 配下の別Gitリポジトリとして扱います。

## 最初に読むもの

1. root 側の作業では [docs/ai/index.md](docs/ai/index.md)
2. Laravel / React / アプリdocs / tests / `src/` 側の作業では `src/AGENTS.md`
3. root と `src/` の両方に関わる場合は、このファイル、[docs/ai/index.md](docs/ai/index.md)、`src/AGENTS.md`、`src/docs/ai/index.md`

`src/` は別Gitリポジトリとして扱うため、GitHub上では必要に応じて `Ryosuke-Shigi/codex-practice001` 側のPRまたはdocsを参照します。

## root 側の詳細ルール

root 側の詳細ルールは [docs/ai/rules/root-repository.md](docs/ai/rules/root-repository.md) を参照してください。

この入口には詳細本文を増やさず、参照先だけを置きます。

## Git境界

- root 側repo: Docker / infra 管理領域
- `src/` 側repo: Laravel / React / app docs / tests 管理領域
- root 側の状態が最新でも `src/` 側が最新とは限らないため、`src/` を触る場合は必ず `src/` 側のGit状態も確認する

## 禁止事項

- `/src` 外に Laravel 用の `app/`、`routes/`、`database/`、`resources/` を新規作成しない
- `.env` の実値、APIキー、DBパスワード、AWSキーなどの秘密情報を書かない
- 目的外のアプリ機能追加、DB変更、Docker構成変更をしない
- 既存の未コミット差分を勝手に変更・削除しない
