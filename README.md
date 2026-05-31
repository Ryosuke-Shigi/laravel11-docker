# API Discovery Hub

API Discovery Hub は、APIs.guru の公開APIカタログ `list.json` を同期キャッシュとして取り込み、公開APIを検索、保存、調査するための Laravel + Docker ポートフォリオアプリです。

このリポジトリでは、AIを丸投げ実装者として扱いません。人間が仕様、責務、DTO、テスト、レビュー境界を握り、ChatGPT / CodexApp / Codex IDE は設計整理、実装補助、差分修正、レビュー観点整理に使います。

## アプリ概要

公開APIを調べるときは、API名、提供元、OpenAPI定義URL、更新日、関連検索を行き来することが多くなります。

このアプリでは、その調査の入口として次の機能を提供します。

- APIs.guru `list.json` から公開APIカタログを取得
- `api_catalog_cache` への同期キャッシュ保存
- APIs.guru から消えたAPIを `is_active=false` として扱う差分同期
- API一覧のキーワード検索、provider 絞り込み、domain 絞り込み
- 更新日時や名称など、アプリ内の指標による並び替え
- URL query による検索条件、並び順、ページ番号の保持
- API詳細でのキャッシュ済みメタ情報表示
- Google検索リンクの表示時生成
- APIごとの調査メモ保存、更新、削除
- Queue による手動同期開始
- Scheduler による定期同期 Job 投入
- API Preview での外部API疎通確認
- モック画面でのUI確認

公開URLは確認後に記載します。

## 見てほしいポイント

このポートフォリオで重視しているのは、機能量だけではなく「AIを制御して開発する運用」です。

- AI駆動開発でも、仕様確定、責務境界、完成判定、本番反映判断は人間が行う
- ADRパターンとレイヤードアーキテクチャで、HTTP入口、ユースケース、業務判断、DB境界、出力整形を分離する
- Controller / Request / Action / Service / Repository / DTO / Factory / Strategy / Responder / Event / Listener の責務を混ぜない
- DTO / ListDTO をレイヤー間の境界として扱い、配列や Model の受け渡しを曖昧にしない
- TDDとテストで、AIが壊してはいけない仕様を固定する
- PR前チェックリストで、目的外の変更、責務違反、秘密情報の混入を確認する

## ドキュメント

AIエージェント用の入口と、設計・運用ドキュメントを分けています。

- [AGENTS.md](AGENTS.md): AIエージェントが最初に読む薄い入口
- [docs/architecture.md](docs/architecture.md): ADRパターンとレイヤードアーキテクチャ
- [docs/dto.md](docs/dto.md): DTO / ListDTO の設計方針
- [docs/testing.md](docs/testing.md): TDDとテスト境界
- [docs/development-flow.md](docs/development-flow.md): 仕様整理からPRまでの流れ
- [docs/pr-checklist.md](docs/pr-checklist.md): PR前チェックリスト
- [docs/security.md](docs/security.md): 秘密情報と本番環境の扱い

## AI駆動開発の運用方針

このリポジトリでは、AIに仕様決定や完成判定を任せません。

- 人間が仕様、責務、境界、DB設計、テスト観点を先に決める
- ChatGPT は設計整理、責務分離の壁打ち、レビュー観点整理に使う
- CodexApp / Codex IDE は既存コード確認、差分作成、実装補助、README / docs 整理に使う
- 最終判断、仕様確定、レビュー、本番反映判断は人間が行う
- `.env` の実値、APIキー、DBパスワード、AWSキーなどの秘密情報はAIに渡さない

「AIで雑に作ったアプリ」ではなく、「人間が設計判断を持ち、AIを補助として使うための運用を持つポートフォリオ」として扱っています。

## アーキテクチャ方針

API Discovery Hub は、ADRパターンとレイヤードアーキテクチャを基準にしています。

ここでいう ADR は Architectural Decision Record ではなく、Action / Domain / Responder の分離を指します。

- Controller は HTTP 入口に限定する
- Request は入力バリデーションに限定する
- Action は 1ユースケースの手順を担当する
- Command は登録、更新、削除、同期開始など状態変更を扱う
- Query は一覧、詳細、検索など状態を変えない取得を扱う
- Service は同期時の業務ルールや状態判断を担当する
- Repository は DB取得、保存、Eloquentクエリ、外部API通信の境界を担当する
- DTO / ListDTO はレイヤー間のデータ受け渡しに使う
- Responder は Inertia props など出力形式の整形を担当する
- Factory は DTO生成や Strategy / Responder 選択を担当する
- Strategy は処理差分やアルゴリズム差分を担当する
- Event / Listener は発生した事実と、その後の副作用を分けて扱う

詳細は [docs/architecture.md](docs/architecture.md) を参照してください。

## DTO / ListDTO 方針

DTO はレイヤー間のデータキャリアとして扱います。

- 単体DTOは1件分のデータを表す
- ListDTOは複数件のDTOを束ねる
- DTO名は必ず「集約名 + 操作 + DTO」にする
- ディレクトリに集約名が含まれていても、DTOクラス名から集約名を省略しない
- DB境界DTO、Repository入力DTOでは `snake_case` を許容する
- 業務DTO、画面出力DTO、Component props 用DTOでは `camelCase` を使う
- DTO の `toArray()` は配列変換までに限定する
- DTO に DBアクセス、業務判断、HTTPレスポンス生成、JSON生成、表示判断を持たせない

詳細は [docs/dto.md](docs/dto.md) を参照してください。

## 画面導線

短時間で見る場合は、まず `/` から全体の入口を確認し、次に `/lab` から実験画面と本番画面の関係を見ると流れを追いやすいです。

- `/`: ポートフォリオ入口
- `/lab`: 実験・機能一覧
- `/api-preview`: 外部API確認用画面
- `/api-catalog`: API Discovery Hub の本番一覧
- `/api-catalog/{apiKey}`: API詳細、調査メモ保存
- `/api-catalog/mock`: UI確認用モック一覧
- `/dance-shorts-radar`: Dance Shorts Radar の通常ランキング

補助的なルートとして、`/api-preview/apis-guru`、`/api-preview/apis-guru/mock`、`/api-preview/apis-guru/mock-error`、`/api-catalog/sync`、`/api-catalog/sync/status`、`/api-catalog/mock/{apiKey}`、`/api-catalog/{apiKey}/notes` があります。

## 技術スタック

- Backend: PHP 8.3, Laravel 11
- Frontend: Inertia, React 19, TypeScript, Vite, Tailwind CSS, motion
- Database / Queue: MySQL 8.0, Redis
- Infrastructure: Docker Compose, nginx, php-fpm, AWS Lightsail
- Development tools: Composer, npm, PHPUnit, Laravel Pint, Mailpit, Adminer

## 起動手順

Docker コマンドは WSL2 Ubuntu 上のプロジェクトルートで実行する前提です。Windows / PowerShell の UNC パス経由で実行すると、bind mount の都合で `docker compose run` が失敗する場合があります。

主な構成要素:

- `nginx`: Laravel の入口
- `php-fpm`: Laravel アプリ実行
- `queue`: Queue worker
- `scheduler`: Laravel Scheduler
- `mysql`: APIカタログキャッシュと保存メモのDB
- `redis`: Queue / Cache 用
- `minio`: ローカル開発用の S3 互換ストレージ
- `mailpit`: メール確認用
- `adminer`: DB確認用

ローカル開発の基本コマンド:

```bash
docker compose build
docker compose up -d nginx php-fpm queue scheduler mysql redis minio mailpit adminer
docker compose run --rm composer install
docker compose run --rm npm install
docker compose run --rm artisan migrate
docker compose run --rm npm npm run build
```

ローカル確認URL:

- Laravel: http://localhost:8080
- Vite: http://localhost:5173
- Mailpit: http://localhost:8025
- Adminer: http://localhost:8081
- MinIO Console: http://localhost:9001

### ローカルS3 / MinIO

本番は AWS S3 を使い、ローカル開発では MinIO を S3 互換ストレージとして使います。
Laravel 側の保存処理は `Storage::disk('s3')` に統一し、接続先の違いは `.env` と Docker Compose で切り替えます。

MinIO は `make up` の全体起動に含めています。単体で起動・確認したい場合は次のコマンドを使います。

```bash
make minio-up
make minio-ps
make minio-logs
```

直接 Docker Compose で確認する場合:

```bash
docker compose up -d minio
docker compose ps minio
docker compose logs --tail=50 minio
```

ローカルの `src/.env` には次の値を設定します。本番用の AWS キーはリポジトリへ書きません。

```dotenv
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=minio
AWS_SECRET_ACCESS_KEY=minio_password
AWS_DEFAULT_REGION=ap-northeast-1
AWS_BUCKET=local-bucket
AWS_ENDPOINT=http://minio:9000
AWS_URL=http://localhost:9000/local-bucket
AWS_USE_PATH_STYLE_ENDPOINT=true
```

MinIO Console で `local-bucket` を作成してから、Laravel から保存確認します。

```bash
make app-clear
docker compose exec php-fpm php artisan tinker
```

Tinker では次を実行します。

```php
Storage::disk('s3')->put('test/hello.txt', 'hello minio');
```

同期処理の手動確認:

```bash
docker compose run --rm artisan api-catalog:sync
docker compose run --rm artisan api-catalog:sync --queue
```

## テスト手順

Laravel のテスト:

```bash
docker compose run --rm artisan test
```

React / TypeScript / Vite のビルド確認:

```bash
docker compose run --rm npm npm run build
```

docs のみの変更では、アプリテスト実行は必須ではありません。ただし、Markdown表示、リンク切れ、目的外のコード変更がないことを確認します。

テスト方針の詳細は [docs/testing.md](docs/testing.md) を参照してください。

## PR運用

PRでは、AIが作った差分であっても説明責任は人間が持ちます。

基本の流れ:

1. 仕様整理
2. 入力定義
3. 出力定義
4. DTO / ListDTO 設計
5. 責務分離
6. テスト観点整理
7. CodexApp / Codex IDE への指示作成
8. 実装
9. テスト実行
10. 差分確認
11. PR作成
12. 人間レビュー
13. main反映

PR作成前には [docs/pr-checklist.md](docs/pr-checklist.md) を使い、目的外の変更、責務違反、DTO境界、テスト、秘密情報の混入を確認します。

## テスト・エラー処理の現状

実装済みの Feature テストでは、API Discovery Hub と API Preview の主要導線を確認しています。

- `ApiCatalogSyncTest`: 同期 Job の Queue 投入、同期開始レスポンス、return_url の制限、同期ステータス、失敗状態の扱いを確認
- `ApiCatalogNoteTest`: API詳細表示 props、保存メモの保存、更新、削除、別APIメモの更新防止、モック詳細で保存しないことを確認
- `ApiPreviewTest`: API Preview 一覧、APIs.guru の実取得時 props、エラーレスポンス時 props、成功モック、エラー確認用モックを確認

外部API取得では、成功レスポンスだけでなく、失敗レスポンスや固定エラー表示の確認導線も用意しています。外部通信に依存しないモック画面により、UI とエラー表示を切り分けて確認できます。

## データ保存方針

- `api_catalog_cache` は同期キャッシュ用テーブルとして扱う
- `raw_payload` は保存しない
- OpenAPI 定義本文、paths、schemas、parameters、responses は最初から保存しない
- Google検索リンクは DB に保存しない
- Google検索リンクは表示時に API名などから生成する
- `domain` は DB カラムとして追加せず、`provider_key` から表示・絞り込み用に扱う
- softDeletes は使わない

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

## セキュリティ

`.env` の実値、APIキー、DBパスワード、AWSキーなどの秘密情報は、README、docs、Issue、PR、AIへの指示文に書きません。

本番DB、本番API、本番環境はAIに直接操作させません。docs に書くのは、環境変数名、用途、取得元、必須/任意、セットアップ手順までに限定します。

詳細は [docs/security.md](docs/security.md) を参照してください。

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
