#!/bin/bash
# =============================================================================
# X Search via Grok (xAI Responses API + x_search tool)
#
# 使い方:
#   bash x_search.sh "検索の指示" [オプション]
#
# オプション:
#   --days N          検索対象日数（デフォルト: 7）
#   --model MODEL     モデルID（デフォルト: grok-4-1-fast-reasoning）
#   --mode MODE       search | ideation（デフォルト: search）
#   --locale LOCALE   ja | global（デフォルト: ja）
#   --out-dir DIR     出力先（デフォルト: data/x-research）
#   --raw-json        レスポンスJSONも保存する
#   --dry-run         リクエストを表示して終了
#
# 前提:
#   - 環境変数 XAI_API_KEY が設定されていること
#   - curl, jq コマンドが使用可能であること
# =============================================================================

set -euo pipefail

# --- デフォルト値 ---
DAYS=7
MODEL="grok-4-1-fast-reasoning"
MODE="search"
LOCALE="ja"
OUT_DIR="data/x-research"
RAW_JSON=false
DRY_RUN=false
PROMPT=""

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
    --days)    DAYS="$2"; shift 2 ;;
    --model)   MODEL="$2"; shift 2 ;;
    --mode)    MODE="$2"; shift 2 ;;
    --locale)  LOCALE="$2"; shift 2 ;;
    --out-dir) OUT_DIR="$2"; shift 2 ;;
    --raw-json) RAW_JSON=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --help)
      echo "使い方: bash x_search.sh \"検索の指示\" [--days N] [--model MODEL] [--mode search|ideation] [--locale ja|global] [--out-dir DIR] [--raw-json] [--dry-run]"
      exit 0
      ;;
    -*)
      echo "不明なオプション: $1" >&2; exit 1 ;;
    *)
      PROMPT="$1"; shift ;;
  esac
done

if [ -z "$PROMPT" ]; then
  echo "エラー: 検索の指示を第1引数に指定してください。" >&2
  echo "  例: bash x_search.sh \"AI領域でXのトレンドを調べて\"" >&2
  exit 1
fi

# --- APIキーの確認 ---
if [ -z "${XAI_API_KEY:-}" ]; then
  echo "エラー: 環境変数 XAI_API_KEY が設定されていません。" >&2
  echo "  .env ファイルに XAI_API_KEY=... を追加するか、環境変数を設定してください。" >&2
  echo "  取得先: https://console.x.ai/" >&2
  exit 1
fi

# --- 依存コマンドの確認 ---
for cmd in curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "エラー: $cmd コマンドが見つかりません。" >&2
    exit 1
  fi
done

# --- 日付計算 ---
TODAY=$(date -u +%Y-%m-%d)
if [[ "$OSTYPE" == "darwin"* ]]; then
  FROM_DATE=$(date -u -v-${DAYS}d +%Y-%m-%d)
else
  FROM_DATE=$(date -u -d "${DAYS} days ago" +%Y-%m-%d)
fi

# --- システムプロンプト構築 ---
if [ "$MODE" = "ideation" ]; then
  SYSTEM_PROMPT="あなたはX(Twitter)のトレンドアナリスト兼コンテンツストラテジスト。
X投稿を検索し、タイムラインの空気感（論点のクラスター）を抽出する。

手順:
1) 広く薄く探索: 関連クエリを12個以上作ってX検索。バズ投稿を優先的に拾う
2) クラスター抽出: 繰り返し出る固有名詞/機能名/言い回しを3-5クラスターにまとめる
3) 補強検索: 抽出したフレーズで追加検索
4) 各クラスターの代表ポストを2つ選ぶ（長文の直接引用はしない）
5) 素材を出力する

出力ルール:
- 各素材にURL（X投稿URL。無ければ一次情報URL）を付ける
- 要約は1-2行、自分の言葉で
- エンゲージ指標（likes, retweets, replies, views。不明はunknown）
- なぜ伸びたか（仮説を3つまで）
- 投稿ネタ案（フック1行を3つ）
- 不確かなゴシップは避け、一次情報/公式発表/本人発言を優先
- 裏が取れない場合は「未確認」と明記
- 投資助言表現は禁止（買い/売り推奨、価格目標等）

出力形式:
1. タイムラインの空気（論点のクラスター）を箇条書き
2. 今日の結論（狙うべき3テーマ）を箇条書き
3. 素材一覧を番号付き
4. URL一覧をまとめて"
else
  SYSTEM_PROMPT="あなたはX(Twitter)のリサーチアシスタント。
X投稿を検索し、指定されたトピックについての情報を収集・整理する。

ルール:
- 一次情報/公式発表/本人発言を優先する
- 裏が取れない場合は「未確認」と明記
- 長文の直接引用は避ける（要旨 + URL）
- 可能な限りX投稿のURLを含める
- エンゲージ指標（likes, retweets等）が分かれば含める
- 日本語と英語の両方で検索する"
fi

if [ "$LOCALE" = "ja" ]; then
  SYSTEM_PROMPT="${SYSTEM_PROMPT}
言語: 日本語で出力。日本語のX投稿を優先的に検索するが、英語投稿も含める。"
else
  SYSTEM_PROMPT="${SYSTEM_PROMPT}
Language: Output in English. Search globally across all languages."
fi

SYSTEM_PROMPT="${SYSTEM_PROMPT}
検索期間: ${FROM_DATE} から ${TODAY} まで（直近${DAYS}日間）"

# --- APIリクエストペイロード構築 ---
PAYLOAD=$(jq -n \
  --arg model "$MODEL" \
  --arg system "$SYSTEM_PROMPT" \
  --arg prompt "$PROMPT" \
  --arg from_date "$FROM_DATE" \
  --arg to_date "$TODAY" \
  '{
    model: $model,
    messages: [
      { role: "system", content: $system },
      { role: "user", content: $prompt }
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

# --- dry-run モード ---
if [ "$DRY_RUN" = true ]; then
  echo "=== DRY RUN: リクエストペイロード ==="
  echo "$PAYLOAD" | jq .
  exit 0
fi

# --- 出力ディレクトリ作成 ---
mkdir -p "$OUT_DIR"
TIMESTAMP=$(date -u +%Y%m%d_%H%M%S)

echo "🔍 X検索を実行中..."
echo "   モデル: ${MODEL}"
echo "   モード: ${MODE}"
echo "   期間: ${FROM_DATE} ~ ${TODAY}（${DAYS}日間）"
echo "   ロケール: ${LOCALE}"
echo ""

# --- APIリクエスト実行 ---
# Responses API エンドポイント
RESPONSE=$(curl -s -X POST "https://api.x.ai/v1/responses" \
  -H "Authorization: Bearer ${XAI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  2>&1)

# Responses API が使えない場合は Chat Completions にフォールバック
if echo "$RESPONSE" | jq -e '.error' &>/dev/null 2>&1; then
  ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message // .error // "Unknown error"')

  # 404 や endpoint not found の場合はフォールバック
  if echo "$ERROR_MSG" | grep -qi "not found\|404\|invalid.*endpoint\|unknown.*route"; then
    echo "⚠️  Responses API 未対応。Chat Completions API にフォールバック..."

    FALLBACK_PAYLOAD=$(jq -n \
      --arg model "$MODEL" \
      --arg system "$SYSTEM_PROMPT" \
      --arg prompt "$PROMPT" \
      --arg from_date "$FROM_DATE" \
      --arg to_date "$TODAY" \
      '{
        model: $model,
        messages: [
          { role: "system", content: $system },
          { role: "user", content: $prompt }
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
      -d "$FALLBACK_PAYLOAD")
  fi
fi

# --- エラーチェック ---
ERROR=$(echo "$RESPONSE" | jq -r '.error.message // .error // empty' 2>/dev/null)
if [ -n "$ERROR" ]; then
  echo "❌ APIエラー: ${ERROR}" >&2
  exit 1
fi

# --- レスポンスからテキストを抽出 ---
# Responses API 形式
CONTENT=$(echo "$RESPONSE" | jq -r '
  .output[]? |
  select(.type == "message") |
  .content[]? |
  select(.type == "output_text") |
  .text // empty
' 2>/dev/null)

# Chat Completions 形式にフォールバック
if [ -z "$CONTENT" ]; then
  CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty' 2>/dev/null)
fi

if [ -z "$CONTENT" ]; then
  echo "❌ レスポンスからテキストを抽出できませんでした。" >&2
  echo "$RESPONSE" | jq . >&2
  exit 1
fi

# --- Citations の抽出 ---
CITATIONS=$(echo "$RESPONSE" | jq -r '
  .citations[]? // empty
' 2>/dev/null)

# --- 結果を保存 ---
OUTPUT_MD="${OUT_DIR}/${TIMESTAMP}_search.md"

{
  echo "# X Search Results"
  echo ""
  echo "- **Timestamp**: ${TIMESTAMP} UTC"
  echo "- **Query**: ${PROMPT}"
  echo "- **Mode**: ${MODE}"
  echo "- **Period**: ${FROM_DATE} ~ ${TODAY} (${DAYS} days)"
  echo "- **Model**: ${MODEL}"
  echo "- **Locale**: ${LOCALE}"
  echo ""
  echo "---"
  echo ""
  echo "$CONTENT"
  if [ -n "$CITATIONS" ]; then
    echo ""
    echo "---"
    echo ""
    echo "## Citations"
    echo "$CITATIONS"
  fi
} > "$OUTPUT_MD"

echo ""
echo "✅ 結果を保存しました: ${OUTPUT_MD}"

# --- 生データの保存 ---
if [ "$RAW_JSON" = true ]; then
  OUTPUT_JSON="${OUT_DIR}/${TIMESTAMP}_search.json"
  echo "$RESPONSE" | jq . > "$OUTPUT_JSON"
  echo "   生データ: ${OUTPUT_JSON}"
fi

# --- 結果の表示 ---
echo ""
echo "=========================================="
echo "$CONTENT"
echo "=========================================="
