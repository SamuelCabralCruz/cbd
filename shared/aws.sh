#!/bin/bash

set_up_aws_profile() {
  local AWS_ACCESS_KEY_ID=$1
  local AWS_SECRET_ACCESS_KEY=$2
  local AWS_REGION=$3
  if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
    echo "AWS_ACCESS_KEY_ID env variable is not set. Quitting."
    exit 1
  fi
  if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
    echo "AWS_SECRET_ACCESS_KEY env variable is not set. Quitting."
    exit 1
  fi
  if [[ -z "$AWS_REGION" ]]; then
    AWS_REGION="us-east-1"
  fi
  aws configure --profile commit-bucket-deploy <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF
}

validate_bucket_name() {
  local BUCKET_NAME=$1
  if [[ -z "$BUCKET_NAME" ]]; then
    echo "bucket-name input is required. Quitting."
    exit 1
  fi
  local IS_REACHABLE
  IS_REACHABLE=$(is_bucket_reachable "$BUCKET_NAME")
  if [[ "$IS_REACHABLE" == 'false' ]]; then
    echo "Unreachable S3 bucket. Quitting."
    exit 1
  fi
}

is_bucket_reachable() {
  local BUCKET_NAME=$1
  aws s3 ls "$BUCKET_NAME" --profile commit-bucket-deploy &> /dev/null
  if [[ $? -eq 0 ]]; then
    echo 'true'
  else
    echo 'false'
  fi
}

validate_cloudfront_dist_id() {
  local CLOUDFRONT_DIST_ID=$1
  if [[ -z "$CLOUDFRONT_DIST_ID" ]]; then
    echo "cloudfront-dist-id input is required. Quitting."
    exit 1
  fi
  local IS_EXISTING
  IS_EXISTING=$(is_existing_cloudfront_dist "$CLOUDFRONT_DIST_ID")
  if [[ "$IS_EXISTING" == 'false' ]]; then
    echo "Non existing cloudfront distribution. Quitting."
    exit 1
  fi
}

is_existing_cloudfront_dist() {
  local CLOUDFRONT_DIST_ID=$1
  aws cloudfront get-distribution --id "$CLOUDFRONT_DIST_ID" --profile commit-bucket-deploy &> /dev/null
  if [[ $? -eq 0 ]]; then
    echo 'true'
  else
    echo 'false'
  fi
}

get_cloudfront_dist_alias() {
  local CLOUDFRONT_DIST_ID=$1
  local CLOUDFRONT_DIST_ALIAS
  aws cloudfront get-distribution --id "$CLOUDFRONT_DIST_ID" --profile commit-bucket-deploy &> test.txt
  cat test.txt
  CLOUDFRONT_DIST_ALIAS=$(jq -r '.Distribution.DistributionConfig.Aliases.Items[0]' text.txt)
  echo "$CLOUDFRONT_DIST_ALIAS"
}

upload_folder() {
  local BUCKET_NAME=$1
  local SRC_DIR=$2
  local DEST_DIR=$3
  aws s3 cp "$SRC_DIR" "s3://$BUCKET_NAME/$DEST_DIR" --recursive --profile commit-bucket-deploy
}

invalidate_cloudfront_dist() {
  local CLOUDFRONT_DIST_ID=$1
  aws cloudfront create-invalidation --distribution-id "$CLOUDFRONT_DIST_ID" --paths '/*' --profile commit-bucket-deploy
}

tear_down_aws_profile() {
  aws configure --profile commit-bucket-deploy <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
}
