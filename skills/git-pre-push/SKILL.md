---
name: git-pre-push
description: ユーザーが「プッシュして」「公開して」「push したい」と言ったときに使う。プッシュ前の確認をスクリプトでまとめて実行し、結果を見て push するスキル。
---

# Git Pre Push

## 概要

プッシュ前の確認コマンドを `scripts/pre_push_check.sh` にまとめ、実行したコマンドも標準出力に表示してから、結果を見て push する。

## 手順

1. リポジトリで確認スクリプトを実行する（読み取り専用）。

```sh
bash ~/.agents/skills/git-pre-push/scripts/pre_push_check.sh
```

2. 出力のブランチが main の場合は、そのまま push して良いかユーザーに確認する。
3. `Upstream` の出力を確認し、未プッシュコミットがあるか/どのコミットかを把握する。上流が無い場合は直近 10 件を確認する。
4. ユーザーが OK なら push する。

```sh
git push
```
