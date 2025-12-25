#!/bin/bash
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $(basename "$0") <collection_name> <point_id> <prompt>" >&2
  echo "e.g. ./store_embedding_prompt.sh \"your_collection_name\" 1 \"エレキギター。アンプにつないで音を出す電気式の弦楽器。\""
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not found in PATH" >&2
  exit 1
fi

COLLECTION_NAME=$1
POINT_ID=$2
PROMPT=$3

echo ""
echo "COLLECTION_NAME=${COLLECTION_NAME}"
echo "POINT_ID=${POINT_ID}"
echo "PROMPT=${PROMPT}"

echo ""
echo "--- embeddingを実行 ---"

# レスポンスの.embeddingの値をEMBEDDINGに格納する
embedding_json=$(curl -s -X POST http://localhost:11434/api/embeddings \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg prompt "$PROMPT" '{model:"bge-m3", prompt:$prompt}')")

EMBEDDING=$(echo "$embedding_json" | jq -c '.embedding')

if [ -z "$EMBEDDING" ] || [ "$EMBEDDING" = "null" ]; then
  echo "Failed to fetch embedding: $embedding_json" >&2
  exit 1
fi

echo "成功。embeddingの先頭を表示 ↓"
echo $(echo "$embedding_json" | jq '.embedding[0:5]')

echo ""
echo "--- ベクトルDBへの登録を実行 ---"

body=$(jq -n \
  --argjson id "$POINT_ID" \
  --arg text "$PROMPT" \
  --argjson vector "$EMBEDDING" \
  '{
    points: [
      {
        id: $id,
        vector: $vector,
        payload: { text: $text }
      }
    ]
  }')


# リクエスト実行 & 実行して返ってくる標準出力内容を標準出力する
curl -s -X PUT "http://localhost:6333/collections/${COLLECTION_NAME}/points?wait=true" \
  -H "Content-Type: application/json" \
  -d "$body" | jq