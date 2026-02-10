---
name: git-pre-commit
description: ユーザーが「コミットして」「コミット作って」「コミット前に確認したい」と言ったときに使う。コミット前の確認をスクリプトでまとめて実行し、結果を見てステージ/コミットするスキル。
---

# Git Pre Commit

## 概要

コミット前の確認コマンドを `scripts/pre_commit_check.sh` にまとめ、実行したコマンドも標準出力に表示してから、結果を見てステージ/コミットする。

## 手順

1. リポジトリで確認スクリプトを実行する（読み取り専用）。

```sh
bash ~/.agents/skills/git-pre-commit/scripts/pre_commit_check.sh
```

2. 出力のブランチが main の場合は、そのままコミットして良いかユーザーに確認する。
3. `Staged diff` / `Worktree diff` を見て、分割コミットが必要か判断し、必要なら具体例を挙げて提案する。
4. 分割する場合は必要なファイルだけをステージする（OK の場合のみ）。

```sh
git add <file> [<file> ...]
```

5. 分割しない場合、または残りをまとめてステージする（OK の場合のみ）。

```sh
git add -A
```

6. `Conventional Commit` のフォーマットに従い、"prefix: 変更内容を簡潔に一文の日本語" の形式でコミットする。

```sh
git commit -m "prefix: 変更内容を簡潔に一文日本語で"
```
