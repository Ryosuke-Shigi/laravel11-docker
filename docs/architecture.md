# Architecture

このドキュメントは、API Discovery Hub で採用する ADRパターンとレイヤードアーキテクチャの責務境界をまとめます。

ここでいう ADR は Architectural Decision Record ではなく、Action / Domain / Responder の分離を指します。

## 採用理由

AIを使った開発では、変更範囲が曖昧なまま実装を進めると、Controller に業務判断が混ざる、DTO がレスポンス生成を始める、Repository がドメインルールを持つ、といった責務違反が起きやすくなります。

ADRパターンとレイヤードアーキテクチャを採用する理由は次のとおりです。

- HTTP入力、ユースケース手順、業務判断、DB境界、出力整形を分離する
- 変更対象をレイヤー単位で限定しやすくする
- テストで固定する単位を明確にする
- AIエージェントへ指示する変更範囲を具体化する
- レビュー時に責務違反を見つけやすくする

## レイヤーの責務

### Controller

Controller は HTTP の入口です。

Request を受け取り、必要な Action を呼び出し、Responder へ渡すまでに限定します。Controller に業務判断、DB操作、表示整形を持たせません。

### Request

Request は入力形式のバリデーションに限定します。

必須、型、文字列長、許容値、URL形式などを確認します。DB状態に基づく業務判断や、画面表示用の整形は行いません。

### Action

Action は 1つのユースケース手順を扱います。

Request や DTO から入力を受け取り、Service、Repository、Factory、Responder に処理を委譲します。Action は手順を表現する場所であり、細かいドメイン判断を抱え込ませません。

### Service

Service は業務判断、ドメインルール、状態判断を扱います。

同期対象を有効とみなす条件、保存可能かどうか、状態遷移の可否など、HTTPやDB実装に依存しない判断を置きます。

DanceShortsRadar の snapshot 比較値計算は `DanceShortSnapshotMetricService` に置きます。`current` / `previous` snapshot から `view_count_delta`、`view_growth_rate`、`views_per_hour` を算出し、許可する比較期間と並び替えキーの正規化を担当します。Service は DB query、YouTube API 呼び出し、Inertia props 生成は行いません。

DanceShortsRadar の snapshot 観測枠は `DanceShortSnapshotPeriodService` で算出します。JST の 00:00〜11:59 / 12:00〜23:59 を12時間枠として扱い、Action 開始時点の時刻から枠の開始・終了を一度だけ固定します。Service は UTC 保存値へ変換した境界を返すだけに留め、DB query や snapshot 保存は行いません。

### Repository

Repository は DB 操作や外部データ取得の境界です。

Eloquent クエリ、永続化、検索条件の適用、外部APIからの取得などを扱います。Repository に業務判断を混ぜず、Service や Action から渡された条件に基づいてデータ操作を行います。

DanceShortsRadar の YouTube 同期では、YouTube API 取得と DB 保存を別 Repository に分けます。YouTube API Repository は search.list / videos.list の呼び出しと DTO 変換だけを担当し、動画本体の insert/update、snapshot 保存、最新 snapshot 取得は DB 保存用 Repository に閉じます。

DanceShortsRadar の snapshot 保存では、既存の `collected_at` を使って JST12時間枠 update/create を行います。DB 保存用 Repository は Action から渡された UTC 境界で `video_id + region_id` の同枠 snapshot を探し、`collected_at DESC / id DESC` の最新1件だけを更新します。同枠に snapshot がなければ作成します。DB 制約による12時間枠の完全な一意保証や `snapshot_period_start` カラム追加は行いません。

DanceShortsRadar の snapshot 専用同期では、Repository は Action / Service から渡された `tracking_status` 条件に基づいて保存済み動画を取得します。active の意味判断は Repository に置かず、上限に達する場合だけ latest snapshot が古い動画、published_at が新しい動画、id昇順で安定取得します。

### DTO

DTO はレイヤー間のデータキャリアです。

InputDTO、OutputDTO、ListDTO、Repository入力DTO、Component props 用DTOなど、境界ごとに必要なデータを明示します。DTO は DBアクセス、業務判断、HTTPレスポンス生成を行いません。

DanceShortsRadar では、YouTube API 由来 DTO と DB 保存 DTO を分けます。動画本体用 DTO は `dance_short_videos` の保存値だけを持ち、snapshot 用 DTO は取得時点の `view_count` / `like_count` / `comment_count` だけを持ちます。`view_count_delta`、`view_growth_rate`、`views_per_hour` は snapshot 比較から算出する派生値として扱い、DB 保存 DTO には含めません。

DanceShortsRadar の追跡状態は `dance_short_videos.tracking_status` で管理します。候補は `active` / `inactive` / `archived` とし、snapshot 保存対象は `active` の動画だけに限定します。`inactive` / `archived` の動画本体は物理削除せず、再観測・比較に使わない状態として残します。

DanceShortsRadar の snapshot cleanup は、sync 後に自動実行するユースケースとして扱います。保持期間は画面最大比較期間 30日 + 余白5日の 35日を初期方針とし、保持期間を超えた `dance_short_video_snapshots` だけを物理削除します。`dance_short_videos`、`dance_short_regions`、`dance_short_search_keywords`、`dance_short_video_categories` は cleanup 対象にしません。

DanceShortsRadar の YouTube API 同期 Scheduler は、`DANCE_SHORT_SYNC_ENABLED` の config / env gate で明示的に有効化した環境だけが `dance-short:sync` を3時間ごとに実行します。Scheduler は起動条件と command 実行だけを担当し、YouTube API 呼び出し、動画保存、snapshot 保存、ランキング計算は Command / Job / Action / Service / Repository 側へ委譲します。local では自動同期を OFF にします。

DanceShortsRadar の snapshot 専用同期 Scheduler は、保存済み active 動画の継続観測として `dance-short:sync-snapshots` を毎時15分・45分に実行します。search.list の発見同期とは別入口にし、YouTube API 呼び出しは videos.list のみです。Scheduler は実行タイミングと `withoutOverlapping()`、既存の sync enabled gate だけを扱い、対象動画取得、50件単位の videos.list 取得、JST12時間枠 update/create は Job / Action / Service / Repository 側へ委譲します。Job 側は固定 uniqueId で snapshot 専用同期全体の同時実行を防ぎます。

DanceShortsRadar の snapshot cleanup Scheduler は、YouTube 同期とは別に `CleanupDanceShortVideoSnapshotsJob` を 1日1回 Queue へ投入します。cleanup は YouTube API を呼ばない DB maintenance のため、`DANCE_SHORT_SYNC_ENABLED` では止めません。保持期間、cutoff 算出、物理削除は既存の cleanup Action / Service / Repository に閉じ、Scheduler には削除条件や DB query を書きません。YouTube API quota は、現時点では発見同期を 3地域 x 3時間ごと x search.list 1回の上限想定とし、地域追加、キーワード追加、ページング追加、手動連打対策の拡張は別工程で扱います。

### Factory

Factory は生成や選択の責務を扱います。

DTO 生成、Strategy 選択、Responder 選択など、生成条件を一箇所に寄せたい場合に使います。Factory にユースケース全体の手順や業務判断を持たせすぎないようにします。

### Strategy

Strategy は処理差分やアルゴリズム差分を差し替えるために使います。

同期方法、検索条件の組み立て、外部APIごとの差分など、同じ目的に対して複数の処理方式がある場合に検討します。

DanceShortsRadar の `displayCardField` では、初期 Inertia 表示と先読み API の両方が同じ `DanceShortDisplayCardStrategyFactory` と Strategy を使います。`RISING`、`ALL`、地域別ランキングの取得差分は Action に重複させず、Strategy が現在タブに必要な 5枚 window だけを Repository から取得します。React 側は受け取った `visibleCards`、`activeIndex`、`activeRank`、`pagination` を使って cache / prefetch / Loading 表示を扱い、sort / filter / ranking 判定は行いません。

### Responder

Responder は出力整形に限定します。

Inertia props、JSONレスポンス、リダイレクトレスポンスなど、外部へ返す形式を整えます。Responder に業務判断やDB操作を持たせません。

### Event / Listener

Event は「何が起きたか」という事実を表します。

Listener は Event を受けた後の副作用を扱います。通知、ログ、追加Job投入など、主処理から分けたい後続処理を置きます。Event 自体に処理手順や業務判断を詰め込まないようにします。

## Command / Query の分け方

Command は状態を変更する処理です。

- 作成
- 更新
- 削除
- 同期開始
- Job投入

Query は状態を変更しない取得処理です。

- 一覧表示
- 詳細表示
- 検索
- 絞り込み
- ステータス確認

Command と Query を分けることで、テスト観点、DTO、Repositoryメソッド、Action の責務が明確になります。

DanceShortsRadar のランキング Query は、保存済み `dance_short_video_snapshots` だけを読み、指定地域と比較期間に基づく表示用 DTO / ListDTO を返します。この Query では YouTube API 呼び出し、Scheduler 追加、Controller / Inertia props 生成、派生値の DB 保存は行いません。

## 責務違反の例

- Controller で Eloquent クエリを書き、業務判断まで行う
- Request で DB を参照し、保存可否の判断を行う
- Action に検索条件、状態遷移、表示整形をすべて書く
- Service が `redirect()` や Inertia props を返す
- Repository が「保存してよいか」という業務判断を行う
- DTO が Model を取得する
- DTO が `response()->json()` を返す
- DTO の `toArray()` で画面表示用ラベルやボタン状態を決める
- Responder が DB を更新する
- Listener に主ユースケースの必須処理を隠す

責務違反が見つかった場合は、機能追加を続ける前に、どのレイヤーへ戻すべきかを人間が判断します。
