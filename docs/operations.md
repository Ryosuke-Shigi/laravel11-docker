# Operations

このドキュメントは、GitHub / PR / CI / deploy / Notion / PDF化 などの運用手順をまとめます。

AIエージェントは差分作成、調査、レビュー補助を行えますが、main反映判断、本番反映判断、秘密情報の扱いは人間が行います。

## 基本方針

- main 直pushは禁止する
- 作業は `feature/xxx` 形式の feature ブランチで行う
- PRで差分、確認結果、レビュー観点を説明する
- CI結果を確認し、ユーザーの明示指示を受けてから merge する
- PRの差分確認・CI確認はChatGPTに依頼する
- CI / status check が存在しない場合は、その旨を報告し、merge可否はユーザー判断にする
- main への merge は、PR差分確認・CI確認後、ユーザーの明示指示を受けて行う
- 本番環境をAIに直接操作させない
- 秘密情報を Issue、PR、README、docs、AIへの指示文に書かない

## GitHub確認の対象

作業確認時は、対象リポジトリと作業ルートを取り違えない。

- `codex-practice001` と `laravel11-docker` を混同しない
- `laravel11-docker` では Laravel 本体は `/src` 配下にある
- GitHub上で確認する前に、対象リポジトリ名・作業ブランチ名・作業ルートを確認する
- push前のローカル作業中は、GitHubに差分が見えなくて当然
- Pull Request作成後に GitHub 側の差分確認を行う

## 作業前確認

作業開始前に、対象リポジトリ・作業ブランチ・作業ルートを確認する。

```bash
pwd
ls
git status
git branch --show-current
```

`laravel11-docker` では、Laravel本体は `/src` 配下にある。

Laravel側の作業では、`/src` を基準に差分・テスト・ビルドを確認する。

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

## featureブランチ作成

作業開始前に main を最新化し、目的に合う `feature/xxx` ブランチを作成します。

```bash
git switch main
git pull --ff-only origin main
git switch -c feature/your-topic
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

PRタイトル・本文・レビューコメントは日本語で書く。クラス名、関数名、型名、コマンド、ライブラリ名、API項目名などの正式な技術表記は英語のまま書いてよい。

PRに書くこと:

- 変更内容
- 変更理由
- 影響範囲
- 確認内容
- テスト結果
- docs / README / AGENTS.md 更新有無
- コメント方針やコメント追加範囲
- 残した判断理由
- レビューしてほしい観点

## CI確認

PR作成後、CIの結果を確認します。PRの差分確認とCI確認はChatGPTに依頼します。

確認すること:

- Laravel test が成功している
- React / TypeScript / Vite build が必要な変更で成功している
- docsのみの変更でアプリテストを省略する場合、PR本文に未実行理由がある
- CI / status check が存在しない場合は、その旨を報告し、CI確認済みとして扱わない
- 失敗時はログを確認し、原因が今回差分か既存要因かを切り分ける

## ChatGPTによるPR確認

Pull Request 作成後、ChatGPTはPR差分確認・CI確認・Notion追加・PDF化までを行います。

- PR差分
- 変更ファイル
- CI / status check
- テスト結果
- docs / README / AGENTS.md 更新有無
- 秘密情報が含まれていないか
- main mergeしてよい状態か

CI / status check が存在しない場合は、その旨を報告し、merge可否はユーザー判断にします。

問題がなければ、必要に応じてNotion更新やPDF化を行います。ChatGPTは、ユーザーの明示指示なしに Pull Request を merge しません。

## ユーザー指示後のmerge

merge は人間が判断します。ChatGPTは、ユーザーの明示指示なしにPRをmergeしません。

merge前に確認すること:

- PR checklist を満たしている
- レビュー指摘が解消している
- CIが通っている、または未実行理由が妥当である
- 秘密情報が混入していない
- main へ反映してよい差分だけが残っている

## PR merge 後の同期

Pull Request を main に merge した後は、次の作業へ入る前にローカル側を main 最新へ戻します。

```bash
git switch main
git pull --ff-only origin main
```

`laravel11-docker` では Docker構成側と Laravel本体 `/src` 側が別Gitの場合があります。

Docker構成側の変更は、親側で pull します。

```bash
cd /var/www/api-discovery-hub
git switch main
git pull --ff-only origin main
```

Laravel本体や React 画面の変更は、`/src` 側で pull します。

```bash
cd /var/www/api-discovery-hub/src
git switch main
git pull --ff-only origin main
```

親側の `git pull` だけで `/src` 側の変更が反映されたとは扱いません。

## laravel11-docker の本番反映方針

`laravel11-docker` は Docker構成側のリポジトリとして扱います。

Docker構成側の変更は本番影響が大きいため、GitHub Actions CDで自動反映せず、当面は人間が差分確認後に手動で反映します。

本番反映が必要になる例:

- `docker-compose.yml` を変更した
- nginx 設定を変更した
- queue / scheduler 構成を変更した
- ports 設定を変更した
- Dockerfile を変更した
- 本番運用に必要な環境変数が増えた

docs / AGENTS.md / templates のみの変更は、本番サービスへ即時反映しなくてよいです。

本番へ手動反映する場合は、最低限以下を確認します。

```bash
cd /var/www/api-discovery-hub
git status
git pull --ff-only origin main
docker compose config
docker compose ps
```

Docker構成を再起動する必要がある場合のみ、内容を確認してから実行します。

```bash
docker compose up -d
```

不用意に以下を実行しません。

```bash
docker compose down -v
docker system prune
docker volume prune
```

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
