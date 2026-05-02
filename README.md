# codex-practice001

Laravel 11 の学習・実験用 Docker 環境です。CodexApp を使ったコーディング練習、ADR パターンやレイヤードアーキテクチャの練習、Git / GitHub 管理を前提にした土台として使います。

このリポジトリで Git 管理する対象は Docker 環境だけです。Laravel アプリ本体は `src/` に配置しますが、`src/` は別リポジトリで管理する前提のため、この環境リポジトリでは Git 管理しません。

Docker コマンドは WSL2 Ubuntu 上のプロジェクトルートで実行する前提です。Windows / PowerShell の UNC パス経由で実行すると、bind mount の都合で `docker compose run` が失敗する場合があります。

## コンテナ構成

- `nginx`: Web サーバー
- `php-fpm`: nginx から受ける Web 実行用 PHP
- `php-cli`: PHP CLI 実行用
- `artisan`: `php artisan` 専用
- `composer`: Composer 専用
- `npm`: npm / Vite 専用
- `mysql`: Laravel 用 DB
- `redis`: cache / queue 用
- `mailpit`: ローカルメール確認用
- `adminer`: DB 確認用
- `queue-worker`: Laravel Queue 練習用
- `scheduler`: Laravel Scheduler 練習用

## 初回ビルド

```bash
docker compose build
```

## Laravel 11 を後から入れる

Laravel 本体は `src/` に入れます。`src/` は別の Git リポジトリとして管理します。

```bash
docker compose run --rm composer create-project laravel/laravel . "11.*"
```

すでに Laravel アプリ用リポジトリがある場合は、`src/` に clone します。

```bash
git clone git@github.com:Ryosuke-Shigi/codex-practice001.git src
```

Laravel インストール後は、必要に応じて `src/.env` を Docker 向けに設定します。

```dotenv
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=password

REDIS_HOST=redis

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
```

## 起動

```bash
docker compose up -d nginx php-fpm mysql redis mailpit adminer
```

Laravel インストール後の初期設定例です。

```bash
docker compose run --rm artisan key:generate
docker compose run --rm artisan migrate
```

## 停止

```bash
docker compose down
```

DB データは named volume に残ります。DB データも消す場合は `docker compose down -v` を使います。

## composer 実行

```bash
docker compose run --rm composer install
docker compose run --rm composer require vendor/package
```

## artisan 実行

```bash
docker compose run --rm artisan list
docker compose run --rm artisan migrate
docker compose run --rm artisan make:controller SampleController
```

## npm 実行

```bash
docker compose run --rm npm install
docker compose run --rm npm run build
```

## Vite 開発サーバー

```bash
docker compose run --rm --service-ports npm npm run dev
```

Vite をブラウザから開けない場合は、Laravel インストール後に次のように host を明示します。

```bash
docker compose run --rm --service-ports npm npm run dev -- --host 0.0.0.0
```

## Queue worker

```bash
docker compose --profile worker up -d queue-worker
```

## Scheduler

```bash
docker compose --profile scheduler up -d scheduler
```

## 確認 URL

- Laravel: http://localhost:8080
- Vite: http://localhost:5173
- Mailpit: http://localhost:8025
- Adminer: http://localhost:8081

Adminer では次の情報で MySQL に接続できます。

- サーバー: `mysql`
- ユーザー名: `laravel`
- パスワード: `password`
- データベース: `laravel`

ホスト側の DB クライアントから直接接続する場合は `127.0.0.1:3307` を使います。Laravel コンテナ内からは `mysql:3306` のままです。

## Git / GitHub 管理

このリポジトリは Docker 環境だけを Git / GitHub で管理する前提です。Docker 設定ファイル、`.gitignore`、README はコミット対象にします。

Laravel アプリ本体の `src/` は別リポジトリで管理するため、このリポジトリでは `.gitignore` により除外します。
