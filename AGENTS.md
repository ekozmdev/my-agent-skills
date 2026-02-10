# Skills Sync Flow

このリポジトリの `skills/` を更新する際は、以下のフローのみを使う。
ワンコマンド自動同期は行わず、差分確認とマージ判断は都度 Codex と実施する。
`skills/` を正とし、`~/.agents/skills` は配布先として扱う。
`skills/.system` はこのリポジトリの管理対象外とし、追加・更新しない。

1. 現在日付でドラフトを作成する。
```sh
DATE=$(date +%F)
mkdir -p .draft
cp -R ~/.agents/skills ".draft/${DATE}-skills"
```

2. ドラフトとこのリポジトリの `skills/` の差分を確認する。
```sh
diff -ruN ".draft/${DATE}-skills" skills
```

3. 差分内容を基に、Codex に `skills/` へのマージを依頼する。

4. マージ後、変更内容をレビューする。
```sh
git status --short
git diff
```

5. このリポジトリの `skills/` を `~/.agents/skills` に完全反映する。
```sh
rsync -a --delete skills/ "$HOME/.agents/skills/"
```

6. 反映後に一致確認する。
```sh
diff -ruN skills "$HOME/.agents/skills"
```
