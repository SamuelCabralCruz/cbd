#!/bin/bash

compute_dest_directory() {
  local PROJECT_NAME=$1
  local BRANCH_NAME=$2
  local PULL_REQUEST_NUMBER=$3
  echo "${PROJECT_NAME}-${BRANCH_NAME,,}-${PULL_REQUEST_NUMBER}"
}