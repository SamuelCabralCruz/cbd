#!/bin/bash

is_already_commented() {
  local GITHUB_TOKEN=$1
  local COMMENTS_URL=$2
  local COMMENT_CONTENT=$3
  curl --request GET \
    --url "$COMMENTS_URL" \
    --header "authorization: Bearer $GITHUB_TOKEN" \
    --header 'content-type: application/json' \
    --header 'accept: application/vnd.github.v3+json' \
    -o "pull_request_comments.json" &> /dev/null
  if [[ $(jq ".[] | select(.body | match(\"$COMMENT_CONTENT\")) | any" pull_request_comments.json) == 'true' ]]; then
    echo 'true';
  else
    echo 'false';
  fi
}

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
