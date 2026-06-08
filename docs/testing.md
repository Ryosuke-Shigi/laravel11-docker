# Testing

このドキュメントは、AI駆動開発におけるテストの役割と、API Discovery Hub のテスト方針をまとめます。

## TDD方針

TDD は、AIに実装を任せるための仕組みではなく、人間が決めた仕様を壊さないための補助線として使います。

仕様、責務境界、入力、出力、例外系を人間が整理し、必要なテストで固定します。AIエージェントは、そのテストと既存設計に沿って差分を作成します。

## Featureテストの役割

Featureテストは、ユーザーやHTTP境界から見たユースケースを固定します。

- 画面が表示できること
- Request バリデーションが効くこと
- Action が期待するユースケース手順を通ること
- Inertia props の主要構造が壊れていないこと
- 保存、更新、削除、同期開始などの状態変更が期待通りであること
- エラー時や外部API失敗時の扱いが壊れていないこと

Action / Featureテストでは、ユースケース単位で「AIが壊してはいけない仕様」を固定します。

## Unitテストの役割

Unitテストは、Service、DTO、Factory、Strategy など、HTTPから切り離せる小さな単位の仕様を固定します。

Service の業務判断や状態判定は、Featureテストだけに頼らず、必要に応じて Unitテストで確認します。

## DTOテストの考え方

DTO は基本的にデータキャリアです。

複雑なテストを増やす対象ではありませんが、次のような場合は最小限のテストを検討します。

- `toArray()` の構造が Inertia props や外部出力に影響する
- ListDTO が複数 DTO の配列化を担う
- snake_case / camelCase の変換境界として使われる
- 欠落すると既存画面やレスポンスが壊れる必須項目がある

DTOテストでは、業務判断ではなくデータ構造が壊れていないことを確認します。

DanceShortsRadar の同期では、YouTube API DTO と DB 保存 DTO の境界をテストで分けます。動画本体保存 DTO に公開指標や raw response が混ざらないこと、snapshot 作成 DTO に `view_count_delta` / `view_growth_rate` / `views_per_hour` のような派生値が混ざらないことを固定します。

## Serviceテストの考え方

Serviceテストでは、業務判断、ドメインルール、状態判断を確認します。

例:

- 保存可能な条件
- 同期対象として扱う条件
- エラー時の状態判断
- 入力値の組み合わせによる分岐

HTTPレスポンス、Inertia props、DBクエリの詳細は Serviceテストへ持ち込まず、必要に応じて Mock や DTO を使って境界を分けます。

## Repository境界の考え方

Repository は DB 操作や外部データ取得の境界です。

検索条件、永続化、Eloquent クエリの結果を確認したい場合は、Featureテストや統合寄りのテストで確認します。Service の業務判断を確認したいだけなら、Repository は Mock に置き換えることを検討します。

DanceShortsRadar の DB 保存 Repository では、`youtube_video_id` による動画本体の insert/update、重複 insert 防止、snapshot 保存、最新 snapshot 取得を確認します。Shorts 判定や伸び率の意味づけは Repository テストへ持ち込まず、Service テストで確認します。

DanceShortsRadar の snapshot 専用同期では、search.list を呼ばず保存済み active 動画だけを videos.list で継続観測することを Feature テストで固定します。active 動画IDは50件単位で `fetchVideoDetails()` へ渡し、JST12時間枠内に既存 snapshot がある場合は create し続けず同枠最新1件を update します。同枠に snapshot がない場合は create し、`collected_at` / `view_count` / `like_count` / `comment_count` が最新値へ更新されることを確認します。

DanceShortsRadar の snapshot 専用同期 Scheduler は、毎時15分・45分の登録、`withoutOverlapping()`、既存の sync enabled gate を Feature テストで固定します。Job は `RefreshDanceShortVideoSnapshotsAction` を呼ぶだけにし、`ShouldBeUnique` の固定 uniqueId で snapshot 専用同期全体の同時実行防止を確認します。

DanceShortsRadar の tracking / retention / cleanup では、Service テストで `active` の動画だけが snapshot 保存対象になること、`inactive` / `archived` が保存対象外になること、最大比較期間 30日から詳細 snapshot 保持期間 35日を算出できることを確認します。

DanceShortsRadar の `displayCardField` は、初期表示と先読み API のどちらも最大5枚の `visibleCards` と `pagination` を返すことを Feature テストで固定します。Factory / Strategy の Unit テストでは `RISING`、`ALL`、地域別タブの Strategy 選択を確認し、Repository テストでは `windowSize + 1` 件取得による `hasNext` 判定用 lookahead と、`startRank` に応じた window 取得を確認します。

Repository / Feature テストでは、保持期間を超えた `dance_short_video_snapshots` だけが物理削除され、35日以内の snapshot、`dance_short_videos`、`dance_short_regions`、`dance_short_search_keywords`、`dance_short_video_categories` が削除されないことを確認します。

Action / Command / Job テストでは、sync 後に snapshot cleanup が実行されること、cleanup 件数が ResultDTO に反映されること、cleanup command と cleanup Job が YouTube API を呼ばず cleanup Action へ委譲することを確認します。DanceShortsRadar の Scheduler は `DANCE_SHORT_SYNC_ENABLED` が true の場合だけ 1時間ごとの同期 Job を dispatch し、false の場合は同期 Job を dispatch しないことを Feature テストで固定します。snapshot cleanup Job は同期有効/無効とは別に 1日1回 dispatch 対象になることも固定します。local で `schedule:run` / `schedule:work` や scheduler コンテナを動かしても、明示的に有効化しない限り YouTube API 同期へ進まず、cleanup は DB maintenance としてだけ実行されることを差分確認の対象にします。

## Mockを使う境界

Mock は、テスト対象の責務を明確にするために使います。

Mockを検討する境界:

- 外部API
- Queue / Job
- Mail / Notification
- 現在時刻
- Serviceテストにおける Repository
- Strategy 選択後の処理差分

ただし、Mock を使いすぎると実際の配線ミスを見逃します。ユースケース全体の確認は Featureテストで補完します。

## AIが壊してはいけない仕様を固定する

AIエージェントによる差分では、意図しない責務移動や出力構造の変更が起きる可能性があります。

そのため、次の仕様はテストで固定することを検討します。

- URL、ルート、主要な画面導線
- Request のバリデーション
- Action のユースケース結果
- Service の業務判断
- DTO / ListDTO の出力構造
- Inertia props の主要キー
- Repository の検索条件
- エラー時の表示や戻り先

## テスト実行コマンド

Laravel のテストは Laravel 実行用コンテナで実行します。

```bash
docker compose run --rm artisan test
```

React / TypeScript / Vite のビルド確認は npm コンテナで実行します。

```bash
docker compose run --rm npm npm run build
```

docs のみの変更では、アプリテストの実行は必須ではありません。ただし、リポジトリの運用上テスト必須の場合は、既存のテストコマンドに従います。
