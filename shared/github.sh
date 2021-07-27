#!/bin/bash

create_pull_request_comment() {
  local GITHUB_TOKEN=$1
  local CREATE_COMMENT_URL=$2
  local COMMENT_CONTENT
  COMMENT_CONTENT=$(echo "$3" | jq -Rs .)
  local OUTPUT_FILE=$4
  curl --request POST \
    --url "$CREATE_COMMENT_URL" \
    --header "authorization: Bearer $GITHUB_TOKEN" \
    --header 'content-type: application/json' \
    --header 'accept: application/vnd.github.v3+json' \
    --data "{\"body\": $COMMENT_CONTENT }" \
    -o "$OUTPUT_FILE" &> /dev/null
}
