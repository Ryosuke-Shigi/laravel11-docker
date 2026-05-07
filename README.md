# API Discovery Hub

API Discovery Hub は、APIs.guru の公開APIカタログ `list.json` を同期キャッシュとして取り込み、公開APIを検索・保存・調査するためのポートフォリオアプリです。

- 公開URL: 確認後に記載
- できること: API一覧検索、provider / domain 絞り込み、詳細確認、調査メモ保存、手動同期、外部API確認、UIモック確認
- 技術スタック: Laravel 11, Docker, Inertia, React, TypeScript, MySQL, Redis
- 設計上の見どころ: ADRパターン、レイヤードアーキテクチャ、DTO、Repository、Service、Action、Responder、Queue
- AI駆動開発の位置づけ: 仕様決定や完成判定は人間が行い、ChatGPT / CodexApp は設計整理・レビュー観点整理・既存コード確認・差分作成の補助として使う

## プロジェクト概要

公開APIを調べるときは、API 名、提供元、OpenAPI 定義 URL、更新日、関連検索を行き来することが多くなります。

このプロジェクトでは、その調査の入口を小さなアプリとして作りながら、Laravel 11 + Inertia + React + TypeScript の構成、ADR パターン、レイヤードアーキテクチャ、CQRS、DTO、Repository、Service、Action、Responder の責務分離を練習・検証しています。

API Discovery Hub は AWS Lightsail での外部公開を前提にしています。ただし、現在この README と設定ファイルから公開URLを確認できなかったため、公開URLは確認後に記載します。

## 公開URL

公開URL: 確認後に記載

ローカル確認 URL は次のとおりです。

- Laravel: http://localhost:8080
- Vite: http://localhost:5173
- Mailpit: http://localhost:8025
- Adminer: http://localhost:8081

## できること

- APIs.guru `list.json` から公開APIカタログを取得
- `api_catalog_cache` への同期キャッシュ保存
- APIs.guru から消えた API を `is_active=false` として扱う差分同期
- API 一覧のキーワード検索、provider 絞り込み、domain 絞り込み
- 更新日時や名称など、このアプリ内の指標による並び替え
- URL query による検索条件、並び順、ページ番号の保持
- API 詳細でのキャッシュ済みメタ情報表示
- Google 検索リンクの表示時生成
- API ごとの調査メモ保存、更新、削除
- Queue による手動同期開始
- Scheduler による定期同期 Job 投入
- API Preview での外部 API 疎通確認
- モック画面での UI 確認

React 画面は、同期 Job の登録と同期ステータス確認の導線を持っています。同期失敗ログや同期履歴表示としての整理は、今後追加予定です。

## 画面導線

短時間で見る場合は、まず `/` から全体の入口を確認し、次に `/lab` から実験画面と本番画面の関係を見ると流れを追いやすいです。

- `/`: ポートフォリオ入口。アプリ全体の起点として見る画面です。
- `/lab`: 実験・機能一覧。API Preview と API Discovery Hub への導線をまとめています。
- `/api-preview`: 外部API確認用画面。APIs.guru の実取得、成功モック、エラーモックの入口です。
- `/api-catalog`: API Discovery Hub の本番一覧。公開APIカタログの検索、絞り込み、並び替え、同期開始を確認できます。
- `/api-catalog/{apiKey}`: API詳細。提供元、preferred version、OpenAPI URL、更新日時、調査メモの保存・更新・削除を確認できます。
- `/api-catalog/mock`: UI確認用モック一覧。外部APIや同期キャッシュに依存せず、一覧UIの見た目と導線を確認できます。

補助的なルートとして、`/api-preview/apis-guru`、`/api-preview/apis-guru/mock`、`/api-preview/apis-guru/mock-error`、`/api-catalog/sync`、`/api-catalog/sync/status`、`/api-catalog/mock/{apiKey}`、`/api-catalog/{apiKey}/notes` があります。

## 技術スタック

- Backend: PHP 8.3, Laravel 11
- Frontend: Inertia, React 19, TypeScript, Vite, Tailwind CSS, motion
- Database / Queue: MySQL 8.0, Redis
- Infrastructure: Docker Compose, nginx, php-fpm, AWS Lightsail
- Development tools: Composer, npm, PHPUnit, Laravel Pint, Mailpit, Adminer

## 設計方針

API Discovery Hub は、ADR パターンとレイヤードアーキテクチャを基準にしています。

- Controller は HTTP 入口に限定する
- Request は入力バリデーションに限定する
- Action は 1 ユースケースの手順を担当する
- Command は登録、更新、削除、同期開始など状態変更を扱う
- Query は一覧、詳細、検索など状態を変えない取得を扱う
- Service は同期時の業務ルールや状態判断を担当する
- Repository は DB 取得・保存、Eloquent クエリ、外部 API 通信の境界を担当する
- DTO はレイヤー間のデータ受け渡しに使う
- Responder は Inertia props など出力形式の整形を担当する
- Factory は DTO 生成や Strategy / Responder 選択を担当する
- Strategy は処理差分やアルゴリズム差分を担当する
- Event / Listener は発生した事実と、その後の副作用を分けて扱う

API Preview と API Discovery Hub 本体は分離しています。Preview 側の Repository / DTO / Responder は、本体側に流用しない方針です。

## AI駆動開発の方針

このリポジトリでは、AI に仕様決定や完成判定を任せません。

- 人間が仕様、責務、境界、DB 設計、テスト観点を先に決める
- ChatGPT は設計整理、責務分離の壁打ち、レビュー観点整理に使う
- CodexApp は既存コード確認、差分作成、実装補助、README 整理に使う
- 最終判断、仕様確定、レビュー、本番反映判断は人間が行う

「AIが自律的に作ったアプリ」ではなく、「人間が設計判断を持ち、AIを補助として使った開発ポートフォリオ」として扱っています。

## テスト・エラー処理

実装済みの Feature テストでは、API Discovery Hub と API Preview の主要導線を確認しています。

- `ApiCatalogSyncTest`: 同期 Job の Queue 投入、同期開始レスポンス、return_url の制限、同期ステータス、失敗状態の扱いを確認
- `ApiCatalogNoteTest`: API詳細表示 props、保存メモの保存・更新・削除、別APIメモの更新防止、モック詳細で保存しないことを確認
- `ApiPreviewTest`: API Preview 一覧、APIs.guru の実取得時 props、エラーレスポンス時 props、成功モック、エラー確認用モックを確認

外部API取得では、成功レスポンスだけでなく、失敗レスポンスや固定エラー表示の確認導線も用意しています。外部通信に依存しないモック画面により、UI とエラー表示を切り分けて確認できます。

今後予定として、Service / Action / Repository の Unit テスト拡充、同期失敗ログ、同期履歴表示、失敗通知の整理を追加していきます。

テスト実行コマンド:

```bash
docker compose run --rm artisan test
docker compose run --rm npm run build
```

## データ保存方針

- `api_catalog_cache` は同期キャッシュ用テーブルとして扱う
- `raw_payload` は保存しない
- OpenAPI 定義本文、paths、schemas、parameters、responses は最初から保存しない
- Google 検索リンクは DB に保存しない
- Google 検索リンクは表示時に API 名などから生成する
- `domain` は DB カラムとして追加せず、`provider_key` から表示・絞り込み用に扱う
- softDeletes は使わない

## Docker構成

Docker コマンドは WSL2 Ubuntu 上のプロジェクトルートで実行する前提です。Windows / PowerShell の UNC パス経由で実行すると、bind mount の都合で `docker compose run` が失敗する場合があります。

主な構成要素:

- `nginx`: Laravel の入口
- `php-fpm`: Laravel アプリ実行
- `queue`: Queue worker
- `scheduler`: Laravel Scheduler
- `mysql`: API カタログキャッシュと保存メモのDB
- `redis`: Queue / Cache 用
- `mailpit`: メール確認用
- `adminer`: DB確認用

ローカル開発の基本コマンド:

```bash
docker compose build
docker compose up -d nginx php-fpm queue scheduler mysql redis mailpit adminer
docker compose run --rm composer install
docker compose run --rm npm install
docker compose run --rm artisan migrate
docker compose run --rm npm run build
```

同期処理の手動確認:

```bash
docker compose run --rm artisan api-catalog:sync
docker compose run --rm artisan api-catalog:sync --queue
```

## ディレクトリ構成

主な配置は次のとおりです。

- `src/app/Http/Controllers`: HTTP 入口
- `src/app/Http/Requests`: 入力バリデーション
- `src/app/Actions`: ユースケース手順
- `src/app/Services`: 業務ルール、状態判断
- `src/app/Repositories`: DB / 外部API境界
- `src/app/DTO`: レイヤー間データ
- `src/app/Responders`: Inertia props などの出力整形
- `src/app/Factories`: DTO や Strategy などの生成・選択
- `src/app/Strategies`: 処理差分
- `src/app/Events`, `src/app/Jobs`: 副作用や非同期処理
- `src/resources/js/Pages`: Inertia / React の画面
- `src/resources/js/Components`: React コンポーネント
- `src/routes/web.php`: 画面ルート
- `src/tests/Feature`: Feature テスト

## 今後予定

- 公開URLの README 反映
- 同期履歴表示と同期失敗ログ
- ポーリングなどによる同期状態表示の改善
- 詳細画面を開いたタイミングで OpenAPI 定義本文を取得する別導線
- paths、schemas、parameters、responses の扱い方の検討
- 保存メモ周辺の表示・入力体験の改善
- API Discovery Hub 一覧・詳細の追加テスト
- Service / Action / Repository の Unit テスト拡充
- Factory / Strategy の使いどころの検証
- Lightsail 運用手順の整理

## 注意事項

この README は、現在実装済みの範囲に合わせています。API Discovery Hub は公開APIを探す補助とAPI調査の入口を目的にしたアプリであり、API の価値や注目度を断定するものではありません。

公開URLは、この README と設定ファイルからは確認できなかったため未記載です。確認後、`公開URL` と `GitHub About 設定案` の Website に反映します。

## GitHub About 設定案

GitHub 右側の About には、次の内容を設定する想定です。GitHub の About 設定そのものは、この README では変更していません。

Description:

```text
Laravel 11 + Docker + Inertia + React で作成した、公開APIを検索・保存・調査できる API Discovery Hub。ADRパターンとレイヤードアーキテクチャを使ったAI駆動開発ポートフォリオ。
```

Website:

```text
公開URLは確認後に設定
```

Topics:

```text
laravel
docker
inertia
react
typescript
portfolio
api-catalog
adr
layered-architecture
ai-driven-development
```
