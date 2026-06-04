# 指示用まとめ

CodexAppへ渡す実装前ゲート用テンプレートです。

共通前提は AGENTS.md と docs に逃がし、このテンプレートには今回の作業に必要な差分だけを書きます。

## 目的

- xxx

## 作業ルート

Laravel本体は `/src`。

Laravel / PHP / artisan / tests / resources / routes / database / npm を扱う場合は、必ず `/src` 基準で確認する。

リポジトリ直下は Docker / Makefile / README / infra 系の管理領域として扱う。

`/src` 外に Laravel 用の `app/`、`routes/`、`database/`、`resources/` を新規作成しない。

## 前提

- 共通前提は `AGENTS.md` / `docs/architecture.md` / `docs/dto.md` / `docs/testing.md` / `docs/logging.md` / `docs/operations.md` / `docs/setup.md` に従う
- 秘密情報は扱わない

## Git運用

- main 直pushは禁止
- 作業ブランチは `feature/xxx` 形式で作成する
- `/feature` ではなく `feature/xxx` と表記する
- CodexAppは feature ブランチへの push 後、Pull Request を作成する
- main への merge は、PR差分確認・CI確認後、ユーザーの明示指示を受けて行う
- PRの差分確認・CI確認はChatGPTに依頼する
- CI / status check が存在しない場合は、その旨を報告し、merge可否はユーザー判断にする
- ChatGPTは、PR差分確認・CI確認・Notion追加・PDF化までは行う
- ChatGPTは、ユーザーの明示指示なしに Pull Request を merge しない
- ChatGPTが差分とCI / status check 有無を確認し、問題がなければ、ユーザーの指示を受けてPRをmergeする
- 指示に明示がない限り、CodexAppは main へ merge しない
- 「mainにmergeしてpushして」という指示は使わない

## 今回触る範囲

- xxx

## 成功条件

- xxx
- PR merge は、ChatGPT確認後でもユーザーの明示指示が必要であることが明記されている
- CI / status check が存在しない場合の報告ルールが明記されている

## 失敗条件

- xxx
- PR差分確認・CI確認後に自動でmergeする前提になっている
- CI / status check が存在しないのに、CI確認済みとして扱う
- ユーザーの明示指示なしにChatGPTがPRをmergeする前提になっている

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

## 完了後に報告すること

- 変更内容:
- 変更ファイル:
- 作業ブランチ:
- push先ブランチ:
- Pull Request URL:
- CI / status check 有無:
- merge判断:
- 確認コマンド:
- テスト結果:
- README更新有無:
- docs更新有無:
- AGENTS.md更新内容:
- 残した判断理由:
- 次に進める作業:

例:

```text
CI / status check 有無:
- GitHub上に status check は存在しません

merge判断:
- PR差分確認後、ユーザーの明示指示を受けてmerge判断
```
