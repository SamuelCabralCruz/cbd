#!/bin/bash

DIR="$(dirname "$0")"
. "$DIR/shared/app.sh"
. "$DIR/shared/aws.sh"
. "$DIR/shared/github.sh"
. "$DIR/shared/validate.sh"

validate_pull_request_context "$GITHUB_EVENT_NAME"

PROJECT_NAME=$1
BUCKET_NAME=$2

BRANCH_NAME=$(jq -r '.pull_request.head.ref' "$GITHUB_EVENT_PATH" | tr  '/' '-')
PULL_REQUEST_NUMBER=$(jq -r '.number' "$GITHUB_EVENT_PATH")
EVENT_TYPE=$(jq -r '.action' "$GITHUB_EVENT_PATH")

set_up_aws_profile "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" "$AWS_REGION"

validate_project_name "$PROJECT_NAME"
validate_bucket_name "$BUCKET_NAME"

if [[ $EVENT_TYPE == 'closed' ]]; then
  FOLDER_NAME=$(compute_folder_name "$PROJECT_NAME" "$BRANCH_NAME" "$PULL_REQUEST_NUMBER")
  remove_folder "$BUCKET_NAME" "$FOLDER_NAME"
else
  echo 'This action is designed to be run with pull_request event types: closed. Quitting.'
  exit 1
fi

tear_down_aws_profile
