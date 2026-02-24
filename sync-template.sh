#!/bin/bash
# sync-template.sh

echo "テンプレートを同期します..."

TEMPLATE_REPO="https://github.com/MemeLLC/agent-system.git"
TEMP_DIR=$(mktemp -d)

git clone --depth 1 "$TEMPLATE_REPO" "$TEMP_DIR"

# ディレクトリの同期
rsync -av --delete "$TEMP_DIR/.agents/" ./.agents/
rsync -av --delete "$TEMP_DIR/.claude/" ./.claude/
rsync -av --delete "$TEMP_DIR/.codex/"  ./.codex/

# ファイルの同期
cp "$TEMP_DIR/.gitignore"   ./.gitignore
cp "$TEMP_DIR/.env.example" ./.env.example

rm -rf "$TEMP_DIR"

echo "テンプレートの同期が完了しました。"
