#!/bin/bash

set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $(basename "$0") <collection_name> <limit> <prompt>" >&2
  echo "e.g. ./similar_search.sh \"your_collection_name\" 5 \"電気で音を増幅する楽器\""
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not found in PATH" >&2
  exit 1
fi

COLLECTION_NAME=$1
LIMIT=$2
PROMPT=$3

echo ""
echo "COLLECTION_NAME=${COLLECTION_NAME}"
echo "LIMIT=${LIMIT}"
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
echo "--- 類似検索を実行 ---"

body=$(jq -n \
  --argjson limit "$LIMIT" \
  --argjson vector "$EMBEDDING" \
  '{
    vector: $vector,
    limit: $limit,
    with_payload: true
  }')


# リクエスト実行 & 実行して返ってくる標準出力内容を標準出力する
curl -s -X POST "http://localhost:6333/collections/${COLLECTION_NAME}/points/search" \
  -H "Content-Type: application/json" \
  -d "$body" | jq
