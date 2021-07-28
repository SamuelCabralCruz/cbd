#!/bin/bash

DIR="$(dirname "$0")"
. "$DIR/shared/app.sh"
. "$DIR/shared/aws.sh"
. "$DIR/shared/github.sh"
. "$DIR/shared/validate.sh"

validate_pull_request_context "$GITHUB_EVENT_NAME"

PROJECT_NAME=$1
BUCKET_NAME=$2
CLOUDFRONT_DIST_ID=$3
STATIC_BUILD_FOLDER=$4

BRANCH_NAME=$(jq -r '.pull_request.head.ref' "$GITHUB_EVENT_PATH" | tr  '/' '-')
PULL_REQUEST_NUMBER=$(jq -r '.number' "$GITHUB_EVENT_PATH")
CREATE_COMMENT_URL=$(jq -r '.pull_request.comments_url' "$GITHUB_EVENT_PATH")
EVENT_TYPE=$(jq -r '.action' "$GITHUB_EVENT_PATH")

set_up_aws_profile "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" "$AWS_REGION"

validate_github_token "$GITHUB_TOKEN"
validate_project_name "$PROJECT_NAME"
validate_bucket_name "$BUCKET_NAME"
validate_cloudfront_dist_id "$CLOUDFRONT_DIST_ID"
validate_static_build_folder "$STATIC_BUILD_FOLDER"

if [[ $EVENT_TYPE =~ ^(opened|reopened|synchronize)$ ]]; then
  FOLDER_NAME=$(compute_folder_name "$PROJECT_NAME" "$BRANCH_NAME" "$PULL_REQUEST_NUMBER")
  upload_folder "$BUCKET_NAME" "$STATIC_BUILD_FOLDER" "$FOLDER_NAME"
  invalidate_cloudfront_dist "$CLOUDFRONT_DIST_ID"
  if [[ $EVENT_TYPE == 'opened' ]]; then
    CLOUDFRONT_DIST_ALIAS=$(get_cloudfront_dist_alias "$CLOUDFRONT_DIST_ID")
    URL="https://${CLOUDFRONT_DIST_ALIAS//\*/$FOLDER_NAME}"
    create_pull_request_comment "$GITHUB_TOKEN" "$CREATE_COMMENT_URL" "$URL" "create_pull_request_comment.txt"
  fi
else
  echo 'This action is designed to be run with pull_request event types: opened, reopened, and synchronize. Quitting.'
  exit 1
fi

tear_down_aws_profile
