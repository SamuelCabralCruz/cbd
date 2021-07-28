#!/bin/bash

DIR="$(dirname "$0")"
. "$DIR/shared/app.sh"
. "$DIR/shared/aws.sh"
. "$DIR/shared/github.sh"
. "$DIR/shared/validate.sh"

validate_push_context "$GITHUB_EVENT_NAME"

BUCKET_NAME=$1
CLOUDFRONT_DIST_ID=$2
SOURCE_DIR=$3
DEST_DIR=$4
PERFORM_CLEAN_UP=$5

set_up_aws_profile "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" "$AWS_REGION"

validate_bucket_name "$BUCKET_NAME"
validate_cloudfront_dist_id "$CLOUDFRONT_DIST_ID"
validate_static_build_folder "$SOURCE_DIR"
validate_boolean "perform-clean-up" "$PERFORM_CLEAN_UP"

if [[ $PERFORM_CLEAN_UP == 'true' ]]; then
  remove_folder "$BUCKET_NAME" "$DEST_DIR"
fi
upload_folder "$BUCKET_NAME" "$SOURCE_DIR" "$DEST_DIR"
invalidate_cloudfront_dist "$CLOUDFRONT_DIST_ID"

tear_down_aws_profile
