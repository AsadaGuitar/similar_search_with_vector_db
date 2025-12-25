#!/bin/bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $(basename "$0") <collection_name>" >&2
  echo "e.g. create_collection.sh \"your_collection_name\""
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not found in PATH" >&2
  exit 1
fi

COLLECTION_NAME=$1

echo ""
echo "COLLECTION_NAME=${COLLECTION_NAME}"

curl -s -X PUT "http://localhost:6333/collections/${COLLECTION_NAME}" \
  -H "Content-Type: application/json" \
  -d '{
    "vectors": { "size": 1024, "distance": "Cosine" }
  }' | jq

