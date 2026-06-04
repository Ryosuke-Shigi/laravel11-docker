# Setup

このドキュメントは、ローカル初期構築と基本確認手順をまとめます。

コマンドは WSL2 Ubuntu 上のプロジェクトルートで実行する前提です。Windows / PowerShell の UNC パス経由では、Docker の bind mount 都合で `docker compose run` が失敗する場合があります。

## 初期構築

Docker image を build します。

```bash
docker compose build
```

Laravel の `.env` を `.env.example` から作成します。

```bash
cp src/.env.example src/.env
```

依存関係をインストールします。

```bash
docker compose run --rm composer install
docker compose run --rm npm install
```

アプリケーションキーを生成します。

```bash
docker compose run --rm artisan key:generate
```

コンテナを起動します。

```bash
docker compose up -d nginx php-fpm queue scheduler mysql redis minio mailpit adminer
```

DB migration を実行します。

```bash
docker compose run --rm artisan migrate
```

必要に応じて seed を実行します。

```bash
docker compose run --rm artisan db:seed
```

Dance Shorts Radar の地域マスタと検索キーワードを使う場合は、対象 Seeder を実行します。

```bash
docker compose run --rm artisan db:seed --class=DanceShortRegionSeeder
docker compose run --rm artisan db:seed --class=DanceShortSearchKeywordSeeder
```

## 必要な環境変数名

値は `src/.env` などリポジトリ外で管理し、README、docs、Issue、PR、AIへの指示文に実値を書きません。

基本:

- `APP_NAME`: アプリ名
- `APP_ENV`: 実行環境
- `APP_KEY`: Laravel の暗号化キー
- `APP_DEBUG`: debug 表示の有無
- `APP_URL`: アプリURL

DB / queue / cache:

- `DB_CONNECTION`: DB接続種別
- `QUEUE_CONNECTION`: Queue接続種別
- `CACHE_STORE`: Cache store
- `REDIS_CLIENT`: Redis client
- `REDIS_HOST`: Redis host
- `REDIS_PASSWORD`: Redis password
- `REDIS_PORT`: Redis port

storage:

- `FILESYSTEM_DISK`: Laravel filesystem disk
- `AWS_ACCESS_KEY_ID`: S3互換ストレージの access key ID
- `AWS_SECRET_ACCESS_KEY`: S3互換ストレージの secret access key
- `AWS_DEFAULT_REGION`: S3 region
- `AWS_BUCKET`: S3 bucket
- `AWS_ENDPOINT`: S3互換 endpoint
- `AWS_URL`: 公開URL用の S3 URL
- `AWS_USE_PATH_STYLE_ENDPOINT`: path style endpoint 使用有無

mail:

- `MAIL_MAILER`: mail driver
- `MAIL_HOST`: mail host
- `MAIL_PORT`: mail port
- `MAIL_USERNAME`: mail username
- `MAIL_PASSWORD`: mail password
- `MAIL_FROM_ADDRESS`: from address
- `MAIL_FROM_NAME`: from name

YouTube / Dance Shorts Radar:

- `YOUTUBE_DATA_API_KEY`: YouTube Data API key
- `YOUTUBE_API_BASE_URL`: YouTube API base URL
- `YOUTUBE_DISCOVER_MAX_RESULTS`: discovery 最大取得件数
- `YOUTUBE_DISCOVER_PUBLISHED_AFTER_DAYS`: discovery 対象日数
- `DANCE_SHORT_SYNC_ENABLED`: 自動同期の有効化
- `DANCE_SHORT_SNAPSHOT_RETENTION_DAYS`: snapshot 保持日数

frontend:

- `VITE_APP_NAME`: Vite 側のアプリ名

## npm build / dev

production build を確認します。

```bash
docker compose run --rm npm npm run build
```

Vite dev server を起動する場合は、service ports を使います。

```bash
docker compose run --rm --service-ports npm run dev -- --host 0.0.0.0
```

## test実行

Laravel のテストを実行します。

```bash
docker compose run --rm artisan test
```

React / TypeScript のテストを実行します。

```bash
docker compose run --rm npm npm run test:run
```

docsのみの変更では、アプリテスト実行は必須ではありません。その場合は、差分確認と未実行理由の明記を行います。

```bash
git status
git diff --check
git diff --stat
```

## 注意点

- `.env` の実値、APIキー、DBパスワード、AWSキー、SSH情報を書かない
- `DANCE_SHORT_SYNC_ENABLED` は、YouTube API同期を明示的に有効化する場合だけ変更する
- 本番環境の `.env` を表示または編集しない
- 本番DB、本番API、本番環境をAIに直接操作させない
- Docker volume を削除する破壊的操作は、目的と影響を確認してから人間が判断する
