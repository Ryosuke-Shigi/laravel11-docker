# Development Flow

このドキュメントは、仕様整理から PR 作成、main 反映までの流れをまとめます。

AIエージェントはこの流れの一部を補助しますが、仕様確定、責務境界、完成判定、本番反映判断は人間が行います。

## MDルーター

作業開始時は [docs/md-router.md](md-router.md) を確認し、作業種別ごとに読むdocsを固定します。

MDルーターの詳細は [docs/md-router.md](md-router.md) を正本とします。

開発フロー、docs構成、feature docs、運用手順が変わった場合は、作業後にMDルーターの追加・削除・修正が必要か確認します。

## 1. 仕様整理

何を作るのか、何を作らないのかを明確にします。

目的、対象ユーザー、画面導線、入力、出力、成功条件、失敗時の扱いを整理します。AIへ依頼する前に、最低限の仕様境界を人間が決めます。

## 2. 入力定義

画面入力、URL query、route parameter、外部API入力、Command 引数などを整理します。

Request バリデーションで確認する形式と、Service で判断する業務ルールを分けます。

## 3. 出力定義

画面表示、Inertia props、JSONレスポンス、リダイレクト、エラー表示などを整理します。

Responder が整形する出力と、Service / Action が返すユースケース結果を分けます。

## 4. DTO / ListDTO 設計

境界ごとに必要な DTO を決めます。

InputDTO、OutputDTO、ListDTO、Repository入力DTO、Component props 用DTOなどを検討します。DTO名は「集約名 + 操作 + DTO」にします。

## 5. 責務分離

Controller、Request、Action、Service、Repository、DTO、Factory、Strategy、Responder、Event、Listener のどこに何を置くかを決めます。

責務が曖昧な場合は、実装前に人間が判断します。

## 6. テスト観点整理

壊してはいけない仕様をテスト観点として整理します。

Featureテストで固定するユースケース、Unitテストで固定する Service / DTO / Factory / Strategy の境界、Mock を使う外部依存を決めます。

## 7. CodexApp / Codex IDE への指示作成

AIエージェントへ渡す指示には、次の情報を含めます。

- 目的
- 変更対象ファイル
- 変更しないファイル
- 責務境界
- DTO方針
- テスト方針
- 実行してよいコマンド
- 実行してはいけない操作
- 完了条件

秘密情報や `.env` の実値は、AIへの指示に含めません。

## 8. 実装

AIエージェントまたは人間が、決めた範囲内で実装します。

最小差分を優先し、ついでのリファクタリングや仕様外の機能追加は行いません。

## 9. テスト実行

変更範囲に応じてテストを実行します。

Laravel の確認:

```bash
docker compose run --rm artisan test
```

React / TypeScript / Vite の確認:

```bash
docker compose run --rm npm npm run build
```

docs のみの変更では、Markdown表示、リンク、差分範囲の確認を優先します。

## 10. 差分確認

`git diff` で変更範囲を確認します。

目的外のコード変更、`.env` の実値、秘密情報、不要なディレクトリ変更が含まれていないことを確認します。

## 11. PR作成

PRでは、目的、変更内容、確認結果、レビューしてほしい観点を簡潔に書きます。

AIが作った差分であっても、説明責任は人間が持ちます。

## 12. 人間レビュー

人間が仕様、責務、DTO、テスト、セキュリティ、差分範囲を確認します。

AIレビューは補助として使えますが、最終判断は人間が行います。

## 13. main反映

レビュー後、main へ反映します。

本番反映が必要な場合は、別途デプロイ手順、環境変数、DB影響、ロールバック方針を確認します。AIに本番環境を直接操作させません。
