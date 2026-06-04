# Instruction Summary Template

CodexAppへ渡す実装前ゲート用テンプレートです。

共通前提は AGENTS.md と docs に逃がし、このテンプレートには今回の作業に必要な差分だけを書きます。

## 目的

- xxx

## 前提

- 共通前提は `AGENTS.md` / `docs/architecture.md` / `docs/dto.md` / `docs/testing.md` / `docs/logging.md` / `docs/operations.md` / `docs/setup.md` に従う
- 秘密情報は扱わない

## 今回触る範囲

- xxx

## 成功条件

- xxx

## 失敗条件

- xxx

## 責務分離

- Controller:
- Request:
- Action:
- Service:
- Repository:
- DTO / ListDTO:
- Responder:
- Component:

## TDD / テスト観点

- 先に固定する仕様:
- Featureテスト観点:
- Unitテスト観点:
- Mockする境界:
- 未実行にする場合の理由:

## 実装対象

- xxx

## 実装しないこと

- xxx

## README / docs 更新要否

- README:
- docs:
- AGENTS.md:

## 確認コマンド

```bash
git status
git diff --check
git diff --stat
```

必要に応じて:

```bash
docker compose run --rm artisan test
docker compose run --rm npm npm run build
```

## 注意点

- `.env` の実値、APIキー、DBパスワード、SSH情報、AWSキーを書かない
- 目的外のコード、DB、Docker構成を変更しない
- 代替実装へ進む前に人間へ確認する

## 実装順

1. xxx
2. xxx
3. xxx
