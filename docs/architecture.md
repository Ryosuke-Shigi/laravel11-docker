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

### Repository

Repository は DB 操作や外部データ取得の境界です。

Eloquent クエリ、永続化、検索条件の適用、外部APIからの取得などを扱います。Repository に業務判断を混ぜず、Service や Action から渡された条件に基づいてデータ操作を行います。

DanceShortsRadar の YouTube 同期では、YouTube API 取得と DB 保存を別 Repository に分けます。YouTube API Repository は search.list / videos.list の呼び出しと DTO 変換だけを担当し、動画本体の upsert、snapshot 作成、最新 snapshot 取得は DB 保存用 Repository に閉じます。

### DTO

DTO はレイヤー間のデータキャリアです。

InputDTO、OutputDTO、ListDTO、Repository入力DTO、Component props 用DTOなど、境界ごとに必要なデータを明示します。DTO は DBアクセス、業務判断、HTTPレスポンス生成を行いません。

DanceShortsRadar では、YouTube API 由来 DTO と DB 保存 DTO を分けます。動画本体用 DTO は `dance_short_videos` の保存値だけを持ち、snapshot 用 DTO は取得時点の `view_count` / `like_count` / `comment_count` だけを持ちます。`view_count_delta`、`view_growth_rate`、`views_per_hour` は snapshot 比較から算出する派生値として扱い、DB 保存 DTO には含めません。

DanceShortsRadar の追跡状態は `dance_short_videos.tracking_status` で管理します。候補は `active` / `inactive` / `archived` とし、snapshot 保存対象は `active` の動画だけに限定します。`inactive` / `archived` の動画本体は物理削除せず、再観測・比較に使わない状態として残します。

DanceShortsRadar の snapshot cleanup は、sync 後に自動実行するユースケースとして扱います。保持期間は画面最大比較期間 30日 + 余白5日の 35日を初期方針とし、保持期間を超えた `dance_short_video_snapshots` だけを物理削除します。`dance_short_videos`、`dance_short_regions`、`dance_short_search_keywords`、`dance_short_video_categories` は cleanup 対象にしません。

DanceShortsRadar の YouTube API 同期 Scheduler はこの段階では追加しません。将来 Scheduler を追加する場合も、`DANCE_SHORT_SYNC_ENABLED` のような config / env gate で明示的に有効化した環境だけが定期同期し、local では自動同期を OFF にします。cleanup は YouTube API を呼ばないため、手動 sync の後続処理や手動 command から実行できます。

### Factory

Factory は生成や選択の責務を扱います。

DTO 生成、Strategy 選択、Responder 選択など、生成条件を一箇所に寄せたい場合に使います。Factory にユースケース全体の手順や業務判断を持たせすぎないようにします。

### Strategy

Strategy は処理差分やアルゴリズム差分を差し替えるために使います。

同期方法、検索条件の組み立て、外部APIごとの差分など、同じ目的に対して複数の処理方式がある場合に検討します。

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
