#!/bin/bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $(basename "$0") <collection_name>" >&2
  echo "e.g. setup__store_demo_point.sh \"your_collection_name\""
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not found in PATH" >&2
  exit 1
fi

COLLECTION_NAME=$1

echo ""
echo "COLLECTION_NAME=${COLLECTION_NAME}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STORE_SCRIPT="${SCRIPT_DIR}/store_embedding_prompt.sh"

chmod +x "$STORE_SCRIPT"

PROMPTS=(
  "エレキギター。アンプにつないで音を出す電気式の弦楽器。"
  "アコースティックギター。電気を使わず、生音で演奏する弦楽器。"
  "ピアノ。鍵盤を押すことで弦を叩いて音を出す鍵盤楽器。"
  "ワイングラス。ワインを飲むために使われる脚付きのガラス製グラス。"
  "日本酒のおちょこ。日本酒を少量ずつ飲むための小さな酒器。"
  "お豆腐。大豆を原料として作られる日本の伝統的な食品。"
  "納豆ごはん。ごはんの上に納豆をかけて食べる日本の家庭料理。"
  "豆大福。餅の中にあんこが入った豆入りの和菓子。"
  "お刺身定食。刺身を主菜とした和食の定食メニュー。"
  "ハンバーガー。パンに肉や野菜を挟んだ洋食のファストフード。"
)

for idx in "${!PROMPTS[@]}"; do
  point_id=$((idx + 1))
  "$STORE_SCRIPT" "$COLLECTION_NAME" "$point_id" "${PROMPTS[$idx]}"
done
