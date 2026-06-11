# Frontend

このドキュメントは、React / TypeScript / Inertia 側の実装方針をまとめます。

## 基本方針

- Component は画面表示責務に限定する
- 本番データ取得、保存、業務判断、権限判断を Component に置かない
- Inertia props は Responder 経由で整形する
- Component props は nullable、empty状態、外部データ由来値を型で明示する
- 表示用の変換は、サーバー側責務や業務判断と混同しない

## UI工程との関係

MOCK / PROTOTYPE / PRODUCT の工程は [ui-development-flow.md](ui-development-flow.md) に従います。

- MOCK では固定データで UI構造と状態表示を確認する
- PROTOTYPE では画面遷移と状態受け渡しを確認する
- PRODUCT では UI契約を引き継ぎ、本データと責務分離へ接続する

PRODUCT へ移すときは、MOCK / PROTOTYPE の固定データや検証用ロジックを引き継がず、表示構造、props、状態、導線、責務境界を引き継ぎます。

## 型とアノテーション

- props型、nullable、empty状態、外部データ由来値は型で明示する
- `any` や型アサーションで不整合を隠さない
- 型だけで意味が伝わらない UI契約はコメントで補足する
- `as` を使う場合は、理由が必要な箇所ではコメントまたはPR本文に残す
- `as unknown as Type` のような二段階アサーションは原則使わない

## 確認コマンド

React / TypeScript / TSX / Vite を変更した場合は、変更範囲に応じて確認します。

```bash
docker compose run --rm npm npm run build
docker compose run --rm npm npm run test:run
```

TypeScript / TSX 変更時は、必要に応じて手元確認として次も実行します。

```bash
docker compose run --rm npm npm run typecheck
```

`npm run typecheck` は現時点では CI 必須ゲートではありません。既存型エラーが残っている間は、typecheck の CI 必須化は別PRで扱います。
