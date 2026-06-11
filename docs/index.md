# Docs Index

このディレクトリは、AI駆動開発で参照する設計・実装・運用ルールをまとめます。

AIエージェントは、最初に `AGENTS.md` とこの目次を確認し、作業内容に応じて必要な docs だけを読みます。Laravel アプリケーション本体は `/src` 配下にあるため、Laravel / PHP / React / tests / npm を扱う作業では `/src` を基準にします。

## 主要ドキュメント

- [development-flow.md](development-flow.md): 仕様整理から PR 作成、main 反映までの流れ
- [ui-development-flow.md](ui-development-flow.md): MOCK / PROTOTYPE / PRODUCT の UI 作成工程
- [coding-standards.md](coding-standards.md): 実装作法、責務境界、型、CI必須ゲートと手元確認コマンド
- [commenting.md](commenting.md): 通常コメント・PHPDoc・JSDoc・UIコメントの運用方針
- [testing.md](testing.md): テスト方針、CI必須ゲート、変更範囲別の確認コマンド
- [frontend.md](frontend.md): React / TypeScript / Inertia のフロントエンド方針
- [ui.md](ui.md): UI設計、状態表示、レスポンシブ確認の方針
- [templates/instruction-summary.md](templates/instruction-summary.md): CodexApp へ渡す指示用まとめの型

## 補助ドキュメント

- [architecture.md](architecture.md): Laravel / ADR / レイヤードアーキテクチャの責務境界
- [dto.md](dto.md): DTO / ListDTO の設計方針
- [logging.md](logging.md): ログ方針、ログ分類、記録してよい情報
- [operations.md](operations.md): GitHub / PR / CI / deploy / 本番確認 / Notion / PDF化の運用手順
- [setup.md](setup.md): 初期構築、Docker、.env.example、migrate、npm の確認手順
- [pr-checklist.md](pr-checklist.md): PR前チェックリスト
- [security.md](security.md): 秘密情報と本番環境の扱い
- [templates/pr-summary.md](templates/pr-summary.md): PR本文用まとめの型

## 使い分け

- UI作業では [ui-development-flow.md](ui-development-flow.md)、[ui.md](ui.md)、[frontend.md](frontend.md) を確認する
- 実装作法や型、責務境界で迷う場合は [coding-standards.md](coding-standards.md) を確認する
- コメントやアノテーションを追加する場合は [commenting.md](commenting.md) を確認する
- テストや CI の扱いは [testing.md](testing.md) と [operations.md](operations.md) を確認する
- 秘密情報、本番環境、merge 判断に関わる場合は作業を止め、人間に確認する
