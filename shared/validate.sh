#!/bin/bash

validate_pull_request_context() {
  local GITHUB_EVENT_NAME=$1
  if [[ $GITHUB_EVENT_NAME != 'pull_request' ]]; then
    echo "This action is designed to be run in pull request context. Quitting."
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

validate_static_build_folder() {
  local STATIC_BUILD_FOLDER=$1
  if [[ -z "$STATIC_BUILD_FOLDER" ]]; then
    echo "static-build-folder input is required. Quitting."
    exit 1
  fi
  if [[ ! -d "$STATIC_BUILD_FOLDER" ]]; then
    echo "static-build-folder input is invalid. Provided path does not exist. Quitting."
    exit 1
  fi
}
