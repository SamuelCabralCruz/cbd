#!/bin/bash

compute_dest_directory() {
  local PROJECT_NAME=$1
  local BRANCH_NAME=$2
  local CONVERTED_BRANCH_NAME
  CONVERTED_BRANCH_NAME="${BRANCH_NAME//[^0-9a-zA-Z]/-}"
  local PULL_REQUEST_NUMBER=$3
  echo "${PROJECT_NAME}-${CONVERTED_BRANCH_NAME,,}-${PULL_REQUEST_NUMBER}"
}