---
name: docker
description: Dockerfile と Compose 設定を作成・更新するスキル。Docker 関連ファイル（Dockerfile、Compose、.dockerignore）を扱うときに使う。Compose ファイル名は常に compose.yaml を使用し、docker-compose.yml は新規作成しない。
---

# Docker Files Workflow

## 適用範囲
- Docker 関連ファイル（`Dockerfile`, `compose.yaml`, `.dockerignore`）を新規作成または更新するときに使う。

## 必須ルール
- Compose ファイル名は必ず `compose.yaml` を使う。
- `docker-compose.yml` が既存でも、新規作成時は `compose.yaml` を優先する。
- Compose 内の機密情報は直書きせず、環境変数参照（`${VAR}`）を使う。
- `env_file` は必要な理由がある場合のみ使う。理由がない場合は使わない。
- `docker compose down -v` は禁止する。
- ボリューム削除は、関連ボリュームを確認してから `docker volume rm` で個別に削除する。

## 実施フロー
- `Dockerfile` が必要か判断する。
- Compose が必要なら `compose.yaml` を作成または更新する。
- `env_file` を使う場合は、採用理由を作業メモまたはPR説明に残す。
- ボリューム削除が必要なら、対象プロジェクトのボリュームを一覧で確認する。
- 一覧で確認した対象のみを `docker volume rm <volume_name>` で削除する。
- 必要に応じて `.env.*.example` を更新する。
- サービス起動・停止手順を README に反映する。

## ボリューム削除の例
- `docker volume ls --filter label=com.docker.compose.project=<project_name>`
- `docker volume rm <volume_name>`

## Review Task
- `compose.yaml` を使っていることを確認する。
- `env_file` を使う場合に採用理由が明記されていることを確認する。
- `docker compose down -v` が手順やドキュメントに含まれていないことを確認する。
- ボリューム削除手順が「一覧確認後に個別削除」になっていることを確認する。
- 作成・編集した Docker 関連ファイルとドキュメントを最終レビューする。
