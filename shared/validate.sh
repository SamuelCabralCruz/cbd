#!/bin/bash

validate_pull_request_context() {
  local GITHUB_EVENT_NAME=$1
  if [[ $GITHUB_EVENT_NAME != 'pull_request' ]]; then
    echo "This action is designed to be run in pull request context. Quitting."
    exit 1
  fi
}

validate_push_context() {
  local GITHUB_EVENT_NAME=$1
  if [[ $GITHUB_EVENT_NAME != 'push' ]]; then
    echo "This action is designed to be run in push context. Quitting."
    exit 1
  fi
}

validate_github_token() {
  local GITHUB_TOKEN=$1
  if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "GITHUB_TOKEN env variable is not set. Quitting."
    exit 1
  fi
}

validate_project_name() {
  local PROJECT_NAME=$1
  if [[ -z "$PROJECT_NAME" ]]; then
    echo "project-name input is required. Quitting."
    exit 1
  fi
  if [[ ! "$PROJECT_NAME" =~ ^[a-z\-]+$ ]]; then
    echo "project-name input is invalid. It should be a lower case kebab string (regex: [a-z\-]+). Quitting."
    exit 1
  fi
}

validate_source_directory() {
  local SOURCE_DIR=$1
  if [[ -z "$SOURCE_DIR" ]]; then
    echo "source-dir input is required. Quitting."
    exit 1
  fi
  if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "source-dir input is invalid. Provided path does not exist. Quitting."
    exit 1
  fi
}

validate_boolean() {
  local NAME=$1
  local VALUE=$2
  if [[ ! $VALUE =~ ^(true|false)$ ]]; then
   echo "$NAME input is invalid. Accepted values are: true or false. Quitting."
  fi
}