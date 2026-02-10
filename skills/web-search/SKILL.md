---
name: web-search
description: "Web検索が必要な場合に実行する。ユーザーからWebで調べてほしいトピックが与えられたときに使う。"
---

# Web Search

Tavily の search/extract をまとめて扱う。

## 使い分け

- 組み込みの Web 検索ツールが使える場合は、そちらを優先する。
- URL が未確定: search
- URL が既知: extract
- 検索してから本文取得: search → extract

## 前提

- `TAVILY_API_KEY` が設定されているかチェックする。
- チェック時はキーの値を出力しない。
- 未設定ならユーザーに設定を依頼する。

## 使い方

### search

```bash
./{current_skill_path}/scripts/search.sh '<json>'
```

```powershell
.\{current_skill_path}/scripts/search.ps1 '<json>'
```

### extract

```bash
./{current_skill_path}/scripts/extract.sh '<json>'
```

```powershell
.\{current_skill_path}/scripts/extract.ps1 '<json>'
```

## パラメーター

### search

- `query` (必須): 検索クエリ。
- `max_results`: 返す件数 (0-20)。
- `search_depth`: `ultra-fast` / `fast` / `basic` / `advanced`。
- `topic`: `general` / `news` / `finance`。
- `include_domains` / `exclude_domains`: 対象ドメインの絞り込み。
- `time_range`: `day` / `week` / `month` / `year`。

```json
{"query":"python async patterns","max_results":5,"search_depth":"basic"}
```

### extract

- `urls` (必須): 抽出対象の URL 配列 (最大 20)。
- `query`: 取得内容の絞り込み。
- `chunks_per_source`: 1-5 (query 指定時)。
- `extract_depth`: `basic` / `advanced`。
- `format`: `markdown` / `text`。
- `timeout`: 1-60 (秒)。

```json
{"urls":["https://example.com/article"],"extract_depth":"basic"}
```

## 例

```bash
./{current_skill_path}/scripts/search.sh '{"query": "python async patterns"}'
```

```bash
./{current_skill_path}/scripts/extract.sh '{"urls": ["https://example.com/article"]}'
```

## スクリプトが使えない場合

```bash
curl --request POST \
	--url https://api.tavily.com/search \
	--header "Authorization: Bearer $TAVILY_API_KEY" \
	--header "Content-Type: application/json" \
	--data '{"query":"python async patterns","max_results":5}'
```

```bash
curl --request POST \
	--url https://api.tavily.com/extract \
	--header "Authorization: Bearer $TAVILY_API_KEY" \
	--header "Content-Type: application/json" \
	--data '{"urls":["https://example.com/article"]}'
```
