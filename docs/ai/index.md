# Root AI Docs Index

- Status: active
- Scope: outer Docker / environment repository

## 目的

このファイルは、外側repoのAI作業用MD索引です。

詳細ルール本文はここに置かず、参照先だけを示します。

## 参照順

1. [AGENTS.md](../../AGENTS.md)
2. [docs/ai/rules/root-repository.md](rules/root-repository.md)
3. Laravel / React / アプリdocs / tests / `src/` を触る場合は [src/AGENTS.md](../../src/AGENTS.md)
4. アプリ側AI docsを確認する場合は [src/docs/ai/index.md](../../src/docs/ai/index.md)

## MD一覧

| Path | Role |
|---|---|
| [docs/ai/rules/root-repository.md](rules/root-repository.md) | root / `src` 境界、Docker管理領域、root `AGENTS.md` から退避した詳細ルール |
| [src/AGENTS.md](../../src/AGENTS.md) | アプリ側作業の入口 |
| [src/docs/ai/index.md](../../src/docs/ai/index.md) | アプリ側AI docsの索引 |

## 配置ルール

- root 側のDocker / 環境repoルールは `docs/ai/` に置く。
- Laravel / React / アプリdocs / testsのルールは `src/docs/ai/` または `src/docs/` 側の既存docsに置く。
- 分類に迷うMDは移動せず、まず該当するindexから参照する。
