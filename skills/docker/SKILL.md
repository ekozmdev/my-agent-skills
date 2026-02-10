---
name: docker
description: Dockerfile と Compose 設定を作成・更新するスキル。Docker 関連ファイル（Dockerfile、Compose、.dockerignore）を扱うときに使う。Compose ファイル名は常に compose.yaml を使用し、docker-compose.yml は新規作成しない。
---

# Docker Files Workflow

- Docker 関連ファイルを新規作成または更新するときに使う。
- Compose ファイル名は必ず `compose.yaml` を使う。
- `docker-compose.yml` が既存であっても、新規に作る場合は `compose.yaml` を優先する。
- Compose 内の機密情報は直書きせず、`env_file` や環境変数参照を使う。
- 必要に応じて `.env.*.example` を更新する。

## Minimal Checklist

- `Dockerfile` が必要か判断する。
- Compose が必要なら `compose.yaml` を作成または更新する。
- サービス起動手順を README に反映する。
- 作成・編集した Docker 関連ファイルを最終レビューする。
