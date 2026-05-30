# DTO

このドキュメントは、API Discovery Hub における DTO / ListDTO の扱いをまとめます。

DTO は単なる配列置き場ではなく、レイヤー間の境界を明示するためのデータキャリアです。

## DTOを境界として扱う理由

AIを使った実装では、配列や Model をそのまま渡し続けると、どのレイヤーがどのデータを必要としているのかが曖昧になります。

DTO を境界として扱う理由は次のとおりです。

- 入力と出力の形を明示する
- Controller、Action、Service、Repository、Responder の責務を分ける
- テストで検証するデータ構造を固定する
- Inertia props や JSONレスポンスの整形を DTO から分離する
- AIエージェントが不要なフィールドや責務を混ぜにくくする

## DTOの種類

### InputDTO

InputDTO は、Request や画面入力からユースケースへ渡す入力を表します。

形式バリデーション後の値を Action や Service に渡すために使います。HTTP Request オブジェクトを Service へ直接渡さないための境界になります。

### OutputDTO

OutputDTO は、Service や Action の結果を表します。

Responder や Component props 用DTOへ渡す前の、ユースケース結果としてのデータを持ちます。HTTPレスポンス形式に依存しない形にします。

### ListDTO

ListDTO は、複数のDTOを束ねるデータキャリアです。

保持している各 DTO の `toArray()` を呼び出して配列化することは許容します。ただし、ページ表示の判断、ボタン表示可否、HTTPレスポンス生成は行いません。

### Component props 用DTO

Component props 用DTO は、Inertia / React コンポーネントに渡す props の構造を固定するために使います。

画面が必要とするデータ構造を明示しますが、表示文言、CSSクラス、画面上の状態判断をDTOへ寄せすぎないようにします。最終的な props 整形は Responder 側の責務です。

### Repository入力DTO

Repository入力DTO は、Repository に渡す検索条件や永続化条件を表します。

DBカラム名との対応が強い場合は、プロパティ名に `snake_case` を許容します。ただし、保存可否や状態遷移の判断は Service 側で行います。

### Service境界DTO

Service境界DTO は、Action と Service、または Service 同士の境界に置く DTO です。

業務判断に必要な値を明示し、HTTP Request、Eloquent Model、Inertia props に依存しない形にします。

### Responder境界DTO

Responder境界DTO は、Action や Service の結果を Responder に渡すための DTO です。

Responder が出力形式へ変換するために必要な値を持ちます。DTO 自体は `response()`、`Inertia::render()`、`redirect()` を呼びません。

## DTO命名規則

DTOクラス名は必ず「集約名 + 操作 + DTO」にします。

例:

- `NoticeCreateDTO`
- `NoticeListDTO`
- `ApiCatalogSearchDTO`
- `SavedApiCreateDTO`

ディレクトリに集約名が含まれていても、DTOクラス名から集約名を省略しません。

悪い例:

- `CreateDTO`
- `ListDTO`
- `SearchDTO`
- `InputDTO`

集約名と操作名をクラス名に含めることで、ファイル単体でも責務が読み取れるようにします。

## DTOプロパティ命名

DB境界DTO、Repository入力DTOでは `snake_case` を許容します。

例:

- `provider_key`
- `api_key`
- `updated_at`

業務DTO、画面出力DTO、Component props 用DTOでは `camelCase` を使います。

例:

- `providerKey`
- `apiKey`
- `updatedAt`

`snake_case` と `camelCase` の変換は、Repository境界、Factory、Responder など、責務が明確な場所で行います。DTOの中で表示用の都合に合わせた変換を増やしすぎないようにします。

## DTOでやらないこと

DTO / ListDTO では次のことを行いません。

- DBアクセスしない
- Eloquent Model を取得しない
- 業務判断しない
- 保存可否や状態遷移を判断しない
- HTTPレスポンスを生成しない
- JSONを直接生成しない
- `response()->json()` を呼ばない
- `Inertia::render()` を呼ばない
- `redirect()` を呼ばない
- View / Inertia / React 用の表示整形をしない
- CSSクラス、表示ラベル、ボタン表示可否を決めない

DTO の `toArray()` は、保持している値を配列へ変換する責務までに限定します。
