#!/bin/bash
# =============================================================================
# X Ideation — Xトレンドから投稿ネタを出すスクリプト
#
# Grokに「空気を拾う探索手順」を固定プロンプトで与え、
# タイムラインの空気感→クラスター→投稿ネタを出力する。
#
# 使い方:
#   bash x_ideation.sh [オプション]
#
# オプション:
#   --topic TOPIC     領域（デフォルト: AI / Web3）
#   --audience AUD    想定読者: investor | engineer | both（デフォルト: both）
#   --count N         素材の数（デフォルト: 5）
#   --hours N         直近何時間を対象（デフォルト: 48）
#   --locale LOCALE   ja | global（デフォルト: ja）
#   --model MODEL     モデルID
#   --out-dir DIR     出力先
#   --raw-json        レスポンスJSONも保存
#   --dry-run         リクエストを表示して終了
#
# 前提:
#   - 環境変数 XAI_API_KEY が設定されていること
# =============================================================================

set -euo pipefail

# --- デフォルト値 ---
TOPIC="AI / Web3"
AUDIENCE="both"
COUNT=5
HOURS=48
LOCALE="ja"
MODEL="grok-4-1-fast-reasoning"
OUT_DIR="data/x-research"
RAW_JSON=false
DRY_RUN=false

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
    --topic)    TOPIC="$2"; shift 2 ;;
    --audience) AUDIENCE="$2"; shift 2 ;;
    --count)    COUNT="$2"; shift 2 ;;
    --hours)    HOURS="$2"; shift 2 ;;
    --locale)   LOCALE="$2"; shift 2 ;;
    --model)    MODEL="$2"; shift 2 ;;
    --out-dir)  OUT_DIR="$2"; shift 2 ;;
    --raw-json) RAW_JSON=true; shift ;;
    --dry-run)  DRY_RUN=true; shift ;;
    --help)
      echo "使い方: bash x_ideation.sh [--topic \"AI\"] [--audience engineer] [--count 5] [--hours 48] [--locale ja]"
      exit 0
      ;;
    *) echo "不明なオプション: $1" >&2; exit 1 ;;
  esac
done

# --- APIキーの確認 ---
if [ -z "${XAI_API_KEY:-}" ]; then
  echo "エラー: 環境変数 XAI_API_KEY が設定されていません。" >&2
  echo "  .env ファイルに XAI_API_KEY=... を追加するか、環境変数を設定してください。" >&2
  exit 1
fi

# --- 日付計算 ---
TODAY=$(date -u +%Y-%m-%d)
if [[ "$OSTYPE" == "darwin"* ]]; then
  DAYS=$(( HOURS / 24 + 1 ))
  FROM_DATE=$(date -u -v-${DAYS}d +%Y-%m-%d)
  YESTERDAY=$(date -u -v-1d +%Y-%m-%d)
else
  DAYS=$(( HOURS / 24 + 1 ))
  FROM_DATE=$(date -u -d "${DAYS} days ago" +%Y-%m-%d)
  YESTERDAY=$(date -u -d "1 day ago" +%Y-%m-%d)
fi

# --- ロケールブロック ---
if [ "$LOCALE" = "ja" ]; then
  LOCALE_BLOCK="
- 日本語圏を主にリサーチする。ただし英語圏の重要トレンドも拾うこと
- 出力は日本語"
else
  LOCALE_BLOCK="
- Search globally across all languages
- Output in English"
fi

# --- 固定プロンプト構築 ---
SYSTEM_PROMPT="目的: X(Twitter)でimpressionsを最大化するための投稿ネタ出し。

前提:
- アカウント: 個人発信
- 想定読者: ${AUDIENCE}
- 領域: ${TOPIC}
- 文体: 常体、ストーリー薄め、結論先出し
- 期間: ${YESTERDAY} と ${TODAY}（直近${HOURS}時間を目安）${LOCALE_BLOCK}

やること（重要: 空気を拾うための探索手順）:

1) まず「広く薄く」探索して、タイムラインの空気（論点のクラスター）を抽出する:
   - ${TOPIC} に対して、広めのクエリを12個以上自分で作って X 検索する
   - 収集した投稿から「繰り返し出てくる固有名詞/機能名/言い回し」を抽出し、3-5クラスターにまとめる（単発の話題はクラスターにしない）
   - 上で抽出した「繰り返し出てくる機能名/短いフレーズ」を2-5個選び、それをクエリとして追加検索して補強する
   - 可能ならバズ投稿を優先的に拾う。使えない場合は候補を多めに拾って上位を選ぶ

2) クラスターごとに代表ポストを2つずつ選ぶ（長文の直接引用はしない）

3) 合計${COUNT}件の「素材」を出す

4) 各素材ごとに以下を必ず出す:
   - url（Xの投稿URL。無ければ一次情報URL）
   - 要約（1-2行、自分の言葉）
   - エンゲージ指標（観測できたものだけ。不明は unknown）
   - なぜ伸びたか（仮説を3つまで）
   - ここから作れる投稿ネタ案（2つ）
   - フック案（1行を3つ）
   - 注意（断定/投資助言に見えない言い回しへの調整点があれば1行）

追加の要求:
- 最初に「タイムラインの空気（論点のクラスター）」を3-5個、各クラスターに代表ポストURLを2つずつ付ける
- 「投稿者が使っている言い回し/キーフレーズ」を各クラスターにつき2-3個（そのまま引用せず、短い言い換えで）
- 不確かなゴシップは避け、一次情報/公式発表/本人発言を優先。裏が取れない場合は「未確認」と明記
- 投資助言に見える表現は禁止（買い/売り推奨、株価や価格の目標・倍化など）

出力形式:
1. タイムラインの空気（論点のクラスター）— 箇条書き
2. 今日の結論（狙うべき3テーマ）— 箇条書き
3. 素材一覧 — 番号付きで${COUNT}件
4. URL一覧 — まとめて"

USER_PROMPT="上記のルールに従って、${TOPIC} 領域のXトレンドを調査し、投稿ネタを${COUNT}件出してください。"

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

echo "🍌 X Ideation 実行中..."
echo "   トピック: ${TOPIC}"
echo "   読者: ${AUDIENCE}"
echo "   素材数: ${COUNT}"
echo "   期間: 直近${HOURS}時間"
echo ""

# --- API呼び出し（Responses API → フォールバック） ---
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
          sources: [{ type: "x" }],
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
OUTPUT_MD="${OUT_DIR}/${TIMESTAMP}_ideation.md"
{
  echo "# X Ideation Report"
  echo ""
  echo "- **Timestamp**: ${TIMESTAMP} UTC"
  echo "- **Topic**: ${TOPIC}"
  echo "- **Audience**: ${AUDIENCE}"
  echo "- **Count**: ${COUNT}"
  echo "- **Period**: ${HOURS}h (${FROM_DATE} ~ ${TODAY})"
  echo "- **Model**: ${MODEL}"
  echo ""
  echo "---"
  echo ""
  echo "$CONTENT"
} > "$OUTPUT_MD"

echo "✅ 保存: ${OUTPUT_MD}"

if [ "$RAW_JSON" = true ]; then
  OUTPUT_JSON="${OUT_DIR}/${TIMESTAMP}_ideation.json"
  echo "$RESPONSE" | jq . > "$OUTPUT_JSON"
  echo "   生データ: ${OUTPUT_JSON}"
fi

echo ""
echo "=========================================="
echo "$CONTENT"
echo "=========================================="
