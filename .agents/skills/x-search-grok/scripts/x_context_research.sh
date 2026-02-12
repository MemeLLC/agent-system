#!/bin/bash
# =============================================================================
# X Context Research — 記事執筆前の周辺リサーチ（Context Pack 生成）
#
# 記事の「地ならし」として、Xの反応 + Webの一次情報を収集し、
# 定義/反論/数字/論点を揃えた Context Pack を生成する。
#
# 使い方:
#   bash x_context_research.sh "トピック" [オプション]
#
# オプション:
#   --audience AUD    engineer | investor | both（デフォルト: engineer）
#   --goal GOAL       記事の狙い（1文。省略時は自動生成）
#   --days N          検索対象日数（デフォルト: 30）
#   --locale LOCALE   ja | global（デフォルト: ja）
#   --model MODEL     モデルID
#   --out-dir DIR     出力先（デフォルト: data/x-research）
#   --raw-json        レスポンスJSONも保存
#   --dry-run         リクエスト表示して終了
#
# 前提:
#   - 環境変数 XAI_API_KEY が設定されていること
# =============================================================================

set -euo pipefail

# --- デフォルト値 ---
AUDIENCE="engineer"
GOAL=""
DAYS=30
LOCALE="ja"
MODEL="grok-4-1-fast-reasoning"
OUT_DIR="data/x-research"
RAW_JSON=false
DRY_RUN=false
TOPIC=""

# --- .env 読み込み ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
if [ -f "$PROJECT_ROOT/.env" ] && [ -z "${XAI_API_KEY:-}" ]; then
  XAI_API_KEY=$(grep -E '^XAI_API_KEY=' "$PROJECT_ROOT/.env" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
  export XAI_API_KEY
fi

# --- 引数パース ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --audience) AUDIENCE="$2"; shift 2 ;;
    --goal)     GOAL="$2"; shift 2 ;;
    --days)     DAYS="$2"; shift 2 ;;
    --locale)   LOCALE="$2"; shift 2 ;;
    --model)    MODEL="$2"; shift 2 ;;
    --out-dir)  OUT_DIR="$2"; shift 2 ;;
    --raw-json) RAW_JSON=true; shift ;;
    --dry-run)  DRY_RUN=true; shift ;;
    --help)
      echo "使い方: bash x_context_research.sh \"トピック\" [--audience engineer] [--goal \"...\"] [--days 30]"
      exit 0
      ;;
    -*) echo "不明なオプション: $1" >&2; exit 1 ;;
    *)  TOPIC="$1"; shift ;;
  esac
done

if [ -z "$TOPIC" ]; then
  echo "エラー: トピックを第1引数に指定してください。" >&2
  echo "  例: bash x_context_research.sh \"ClaudeにX検索を足してリサーチを自動化する\"" >&2
  exit 1
fi

if [ -z "${XAI_API_KEY:-}" ]; then
  echo "エラー: 環境変数 XAI_API_KEY が設定されていません。" >&2
  echo "  .env ファイルに XAI_API_KEY=... を追加するか、環境変数を設定してください。" >&2
  exit 1
fi

# --- 日付計算 ---
TODAY=$(date -u +%Y-%m-%d)
if [[ "$OSTYPE" == "darwin"* ]]; then
  FROM_DATE=$(date -u -v-${DAYS}d +%Y-%m-%d)
else
  FROM_DATE=$(date -u -d "${DAYS} days ago" +%Y-%m-%d)
fi

# --- ゴール自動生成 ---
[ -z "$GOAL" ] && GOAL="「${TOPIC}」について、読者（${AUDIENCE}）に有用な記事を書く"

# --- ロケール ---
if [ "$LOCALE" = "ja" ]; then
  LANG_BLOCK="出力は日本語。日本語と英語の両方でX検索する。"
else
  LANG_BLOCK="Output in English. Search in English primarily."
fi

# --- Context Pack 生成用プロンプト ---
SYSTEM_PROMPT="あなたは記事執筆前の周辺リサーチを行うリサーチャー。
「書く前の地ならし」として、トピックに関する一次情報・定義・反論・数字を収集し、
記事が「薄くならない」状態を作ることが目的。

${LANG_BLOCK}

以下のContext Pack形式で出力すること:

## Meta
- Timestamp (UTC): ${TODAY}
- Topic: ${TOPIC}
- Target audience: ${AUDIENCE}
- Goal: ${GOAL}

## Topic (1 sentence)
トピックを1文で定義

## Why Now (3 bullets)
なぜ今このトピックが重要か、3つ

## Key Questions (5-8)
読者が持つであろう疑問を5-8個

## Terminology / Definitions
記事で使う用語の定義。誤解を潰す。
各用語に Definition と Source を付ける

## Primary Sources (must-have)
公式ドキュメント / 論文 / 仕様 / 公式発表 のURL付き

## Secondary Sources (nice-to-have)
解説記事 / チュートリアル / まとめ のURL付き

## X上の反応・トレンド
Xでの代表的な投稿・意見・論争をまとめる。
URL付き、エンゲージ指標付き

## Contrasts / Counterpoints (at least 1)
反論・制限・リスクを最低1つ。
Claim → Counter → Evidence の形式

## Data Points (dated)
数字・仕様・制限。必ず As of (参照日) を付ける。
Metric / Value / As of / Source の形式

## What We Can Safely Say (publish-safe phrasing)
記事で安全に書ける表現

## What We Should Not Say (risk)
書くとリスクがある表現（誇大、未確認、投資助言等）

## Suggested Angles (3)
記事の切り口を3つ提案

## Outline Seeds (3-6 headings)
記事の見出し候補

## Sources (URL list)
全URLの一覧"

USER_PROMPT="トピック「${TOPIC}」について周辺リサーチを行い、Context Packを作成してください。
想定読者: ${AUDIENCE}
記事の狙い: ${GOAL}

Xでの反応・トレンドと、Web上の一次情報の両方を調べること。"

# --- ペイロード構築 ---
PAYLOAD=$(jq -n \
  --arg model "$MODEL" \
  --arg system "$SYSTEM_PROMPT" \
  --arg user "$USER_PROMPT" \
  --arg from_date "$FROM_DATE" \
  --arg to_date "$TODAY" \
  '{
    model: $model,
    messages: [
      { role: "system", content: $system },
      { role: "user", content: $user }
    ],
    tools: [
      {
        type: "x_search",
        x_search: {
          from_date: $from_date,
          to_date: $to_date
        }
      },
      {
        type: "web_search"
      }
    ]
  }'
)

if [ "$DRY_RUN" = true ]; then
  echo "=== DRY RUN ==="
  echo "$PAYLOAD" | jq .
  exit 0
fi

mkdir -p "$OUT_DIR"
TIMESTAMP=$(date -u +%Y%m%d_%H%M%S)

echo "📝 Context Research 実行中..."
echo "   トピック: ${TOPIC}"
echo "   読者: ${AUDIENCE}"
echo "   期間: ${DAYS}日間"
echo "   ゴール: ${GOAL}"
echo ""

# --- API呼び出し ---
RESPONSE=$(curl -s -X POST "https://api.x.ai/v1/responses" \
  -H "Authorization: Bearer ${XAI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  2>&1)

# フォールバック
if echo "$RESPONSE" | jq -e '.error' &>/dev/null 2>&1; then
  ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message // .error // ""')
  if echo "$ERROR_MSG" | grep -qi "not found\|404\|invalid.*endpoint"; then
    echo "⚠️  Responses API 未対応。Chat Completions にフォールバック..."
    FALLBACK=$(jq -n \
      --arg model "$MODEL" \
      --arg system "$SYSTEM_PROMPT" \
      --arg user "$USER_PROMPT" \
      --arg from_date "$FROM_DATE" \
      --arg to_date "$TODAY" \
      '{
        model: $model,
        messages: [
          { role: "system", content: $system },
          { role: "user", content: $user }
        ],
        search_parameters: {
          mode: "auto",
          sources: [{ type: "x" }, { type: "web" }],
          from_date: $from_date,
          to_date: $to_date
        }
      }'
    )
    RESPONSE=$(curl -s -X POST "https://api.x.ai/v1/chat/completions" \
      -H "Authorization: Bearer ${XAI_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "$FALLBACK")
  fi
fi

# --- エラーチェック ---
ERROR=$(echo "$RESPONSE" | jq -r '.error.message // .error // empty' 2>/dev/null)
if [ -n "$ERROR" ]; then
  echo "❌ APIエラー: ${ERROR}" >&2
  exit 1
fi

# --- テキスト抽出 ---
CONTENT=$(echo "$RESPONSE" | jq -r '
  .output[]? | select(.type == "message") |
  .content[]? | select(.type == "output_text") | .text // empty
' 2>/dev/null)
[ -z "$CONTENT" ] && CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty' 2>/dev/null)

if [ -z "$CONTENT" ]; then
  echo "❌ レスポンスからテキストを抽出できませんでした。" >&2
  exit 1
fi

# --- 保存 ---
OUTPUT_MD="${OUT_DIR}/${TIMESTAMP}_context.md"
echo "$CONTENT" > "$OUTPUT_MD"
echo "✅ Context Pack を保存: ${OUTPUT_MD}"

if [ "$RAW_JSON" = true ]; then
  OUTPUT_JSON="${OUT_DIR}/${TIMESTAMP}_${LOCALE}_context.json"
  echo "$RESPONSE" | jq . > "$OUTPUT_JSON"
  echo "   生データ: ${OUTPUT_JSON}"
fi

echo ""
echo "=========================================="
echo "$CONTENT"
echo "=========================================="
