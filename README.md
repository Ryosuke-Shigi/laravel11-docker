# API Discovery Hub

API Discovery Hub は、APIs.guru の公開APIカタログ `list.json` を同期キャッシュとして取り込み、公開APIを探す補助とAPI調査の入口にするためのポートフォリオアプリです。

このアプリは AWS Lightsail で外部公開済みです。公開画面では、一覧検索、絞り込み、詳細確認、調査メモの保存までを確認できます。

## 作った理由

公開APIを調べるときは、API 名、提供元、OpenAPI 定義 URL、更新日、関連検索を行き来することが多くなります。

このプロジェクトでは、その調査の入口を小さなアプリとして作りながら、Laravel 11 + Inertia + React + TypeScript の構成、ADR パターン、レイヤードアーキテクチャ、CQRS、DTO、Repository、Service、Action、Responder の責務分離を練習・検証しています。

AI に実装を丸投げするのではなく、人間が仕様、責務、境界、DB 設計、テスト観点を決めたうえで、CodexApp / ChatGPT を開発補助として使う前提です。

## 使用技術

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

API Preview と API Discovery Hub 本体は分離しています。Preview 側の Repository / DTO / Responder は、本体側に流用しない方針です。

## 主な機能

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

## 今できること

- `/` からポートフォリオ入口を開く
- `/lab` から API Preview と API Discovery Hub へ移動する
- `/api-catalog` で公開APIカタログを検索・絞り込み・並び替えする
- 一覧から `/api-catalog/{apiKey}` の詳細画面へ移動する
- 詳細画面で API の提供元、preferred version、OpenAPI URL、更新日時を確認する
- 詳細画面で調査メモを保存・更新・削除する
- 一覧画面から API カタログ同期 Job を Queue に登録する
- `php artisan api-catalog:sync` で同期処理を CLI 実行する
- `php artisan api-catalog:sync --queue` で同期 Job を Queue に登録する

React 画面は、同期 Job の登録完了までを表示します。同期完了判定、失敗通知、同期履歴表示はまだ持っていません。

## 今後追加予定

- 同期履歴テーブルと同期失敗ログ
- ポーリングなどによる同期状態表示
- 詳細画面を開いたタイミングで OpenAPI 定義本文を取得する別導線
- paths、schemas、parameters、responses の扱い方の検討
- 保存メモ周辺の表示・入力体験の改善
- API Discovery Hub 一覧・詳細の追加テスト
- Service / Action / Repository の Unit テスト拡充
- Factory / Strategy の使いどころの検証
- Lightsail 運用手順の整理

## データ保存方針

- `api_catalog_cache` は同期キャッシュ用テーブルとして扱う
- `raw_payload` は保存しない
- OpenAPI 定義本文、paths、schemas、parameters、responses は最初から保存しない
- Google 検索リンクは DB に保存しない
- Google 検索リンクは表示時に API 名などから生成する
- `domain` は DB カラムとして追加せず、`provider_key` から表示・絞り込み用に扱う
- softDeletes は使わない

## 主なルート

- `GET /`: ポートフォリオ入口
- `GET /lab`: 検証画面一覧
- `GET /api-preview`: 外部 API 疎通確認用の入口
- `GET /api-preview/apis-guru`: APIs.guru 実取得確認
- `GET /api-catalog`: API Discovery Hub 本番一覧
- `POST /api-catalog/sync`: 同期 Job 登録
- `GET /api-catalog/{apiKey}`: API Discovery Hub 本番詳細
- `POST / PATCH / DELETE /api-catalog/{apiKey}/notes`: 保存メモ操作
- `GET /api-catalog/mock`: UI 確認用モック一覧
- `GET /api-catalog/mock/{apiKey}`: UI 確認用モック詳細

## ローカル開発

Docker コマンドは WSL2 Ubuntu 上のプロジェクトルートで実行する前提です。Windows / PowerShell の UNC パス経由で実行すると、bind mount の都合で `docker compose run` が失敗する場合があります。

```bash
docker compose build
docker compose up -d nginx php-fpm queue scheduler mysql redis mailpit adminer
docker compose run --rm composer install
docker compose run --rm npm install
docker compose run --rm artisan migrate
docker compose run --rm npm run build
```

ローカル確認 URL は次のとおりです。

- Laravel: http://localhost:8080
- Vite: http://localhost:5173
- Mailpit: http://localhost:8025
- Adminer: http://localhost:8081

## テスト

現時点では Feature テストを中心に、API Preview、API Catalog 同期、保存メモ操作の確認を追加しています。

```bash
docker compose run --rm artisan test
docker compose run --rm npm run build
```

## 注意事項

この README は、現在実装済みの範囲に合わせています。API Discovery Hub は公開APIを探す補助とAPI調査の入口を目的にしたアプリであり、API の価値や注目度を断定するものではありません。
