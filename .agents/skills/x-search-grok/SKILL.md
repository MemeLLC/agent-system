---
name: x-search-grok
version: 1.0.0
description: >
  xAI API（Grok）を使ってX(Twitter)のリアルタイム検索・トレンド分析を行う。
  curlによるREST API呼び出しでGrokにX検索を委任し、
  トレンド発見、投稿ネタ出し、競合SNS分析、業界の空気感の把握を行う。
  ユーザーが以下のいずれかに言及した場合にトリガーする:
  X検索、Twitter検索、Xのトレンド、ツイート検索、SNSリサーチ、
  Xで何が話題、バズっている投稿、ソーシャルリスニング、
  投稿ネタ、ツイートネタ、Xでの反応、タイムラインの空気、
  Grokで検索、xAI API、トレンドリサーチ。
  Claude CodeやChatGPTのWebSearchではX投稿の検索精度が低いため、
  このSkillでGrokをX検索専用レイヤーとして挟むことで解決する。
---

# X Search via Grok（xAI API）Skill

## Overview

Claude Code / ChatGPT のWeb検索はX(Twitter)投稿の検索が弱い。
これは能力の問題ではなく、X投稿のリアルタイムデータへのアクセス手段の問題。

このSkillはxAI API（Grok）を「X検索専用マイクロサービス」として呼び出し、
X上のトレンド・投稿・空気感を高精度に取得する。

**Grokが強い理由**: X社(xAI)が開発しており、Xの投稿データに直接アクセスできる。
`x_search` ツールを使うと、X投稿をリアルタイムに検索・要約する機能が使える。

## 前提条件

- 環境変数 `XAI_API_KEY` が設定されていること
  - `.env` ファイルに `XAI_API_KEY=...` として保存されている
  - 取得先: https://console.x.ai/ でサインアップ → APIキー発行
  - 従量課金制（事前チャージが必要。1回の呼び出しは約$0.10）
- `curl`, `jq` コマンドが使用可能であること

## APIキーの読み込み

スクリプト実行前に `.env` からAPIキーを読み込む:

```bash
# プロジェクトルートの .env から読み込み
export $(grep XAI_API_KEY .env | xargs)
```

または各スクリプトに `--env` オプションで `.env` ファイルのパスを渡せる。

## モデル選択

| モデル | 用途 | 特徴 |
|--------|------|------|
| `grok-4-1-fast-reasoning` | **推奨。** X検索 + 推論 | 高速、推論あり、ツール対応 |
| `grok-4-fast` | 高速な汎用チャット | Reasoning なし、軽量 |
| `grok-4` | 最高品質 | 最も賢いが遅い・高い |

デフォルトは `grok-4-1-fast-reasoning`。

## 3つのモード

### 1. 汎用検索（x_search.sh）

X上のトピック検索、競合分析、空気感把握に使う基本モード。

```bash
bash .agents/skills/x-search-grok/scripts/x_search.sh "AIエージェントについてXで何が話題か調べて"
```

オプション:
- `--days N` — 検索対象日数（デフォルト: 7）
- `--mode search|ideation` — モード（デフォルト: search）
- `--locale ja|global` — ロケール（デフォルト: ja）
- `--model MODEL` — モデルID
- `--out-dir DIR` — 出力先（デフォルト: data/x-research）
- `--raw-json` — レスポンスJSONも保存
- `--dry-run` — リクエスト表示して終了

### 2. 投稿ネタ出し（x_ideation.sh）

Xのトレンドを調査し、投稿ネタを生成する専用モード。

```bash
bash .agents/skills/x-search-grok/scripts/x_ideation.sh --topic "AI / Web3" --count 5
```

オプション:
- `--topic TOPIC` — 領域（デフォルト: AI / Web3）
- `--audience AUD` — 想定読者: investor | engineer | both（デフォルト: both）
- `--count N` — 素材数（デフォルト: 5）
- `--hours N` — 直近何時間を対象（デフォルト: 48）

詳細なプロンプトテンプレート: [references/ideation_prompt.md](references/ideation_prompt.md)

### 3. 記事前リサーチ（x_context_research.sh）

記事執筆前の「地ならし」として、X + Webの情報を収集しContext Packを生成。

```bash
bash .agents/skills/x-search-grok/scripts/x_context_research.sh "ClaudeにX検索を足してリサーチを自動化する"
```

オプション:
- `--audience AUD` — engineer | investor | both（デフォルト: engineer）
- `--goal GOAL` — 記事の狙い（省略時は自動生成）
- `--days N` — 検索対象日数（デフォルト: 30）

テンプレート: [references/context_pack_template.md](references/context_pack_template.md)

## 基本ワークフロー

### トレンド発見（空気感の把握）

```bash
bash .agents/skills/x-search-grok/scripts/x_search.sh \
  "AI / Web3領域で直近24時間にXで話題になっていることを調べて、論点のクラスターを3-5個にまとめて" \
  --days 1
```

### 特定トピックの深掘り

```bash
bash .agents/skills/x-search-grok/scripts/x_search.sh \
  "Claude Codeの最新アップデートについてXでの反応を調べて" \
  --days 7
```

### 投稿ネタ出し

```bash
bash .agents/skills/x-search-grok/scripts/x_ideation.sh \
  --topic "AI開発ツール" --audience engineer --count 5
```

### 競合SNS分析

```bash
bash .agents/skills/x-search-grok/scripts/x_search.sh \
  "Anthropicに関するXでの最近の投稿を分析して"
```

### 記事前リサーチ

```bash
bash .agents/skills/x-search-grok/scripts/x_context_research.sh \
  "ClaudeにX検索を足してリサーチを自動化する" \
  --audience engineer --days 14
```

## プロンプト設計のベストプラクティス

1. **制約を明確にする**: 「AIトレンド 日本語 直近24時間」のように範囲を限定
2. **出力フォーマットを指定する**: 箇条書き、URL付き、数値付きなど
3. **探索→深掘りの2段階**: まず広く薄く→見つけたクラスターを追加検索で補強
4. **一次情報を優先**: 公式発表 > 本人発言 > 二次情報
5. **未確認は「未確認」と明記**: ゴシップや推測は避ける

## 出力

全ての結果は `data/x-research/` に保存される:

- `YYYYMMDD_HHMMSS_search.md` — 汎用検索の分析結果
- `YYYYMMDD_HHMMSS_ideation.md` — 投稿ネタ出しレポート
- `YYYYMMDD_HHMMSS_context.md` — Context Pack
- `*_search.json` / `*_ideation.json` — 生データ（`--raw-json` 指定時）

## スクリプト一覧

| スクリプト | 用途 |
|-----------|------|
| `scripts/x_search.sh` | X検索の基本スクリプト（Responses API） |
| `scripts/x_ideation.sh` | 投稿ネタ出し専用（定型プロンプト込み） |
| `scripts/x_context_research.sh` | 記事前の周辺リサーチ（Context Pack生成） |

## 制限事項

- xAI APIは従量課金制。1回の呼び出しで約$0.05〜$0.30（モデルとトークン量による）
- X検索の結果はGrokのフィルタリングを通るため、全投稿が取得できるわけではない
- バズ検索オペレータ（`min_faves:500` 等）はxAI API経由では使えない場合がある
- 投資助言に見える表現は禁止（買い/売り推奨、価格目標等）
- 長文の直接引用は避ける（要旨 + URL で参照可能にする）

## トラブルシューティング

| 問題 | 対処法 |
|------|--------|
| `XAI_API_KEY` 未設定 | `.env` ファイルを確認。未設定なら https://console.x.ai/ で取得 |
| 残高不足エラー | xAIコンソールで残高を確認・チャージ |
| レスポンスが遅い | `grok-4-1-fast-reasoning` を使う。`grok-4` は遅い |
| X投稿が見つからない | 日付範囲を広げる / 検索クエリを英語に切り替える |
| APIエラー 429 | レート制限。数分待ってリトライ |
