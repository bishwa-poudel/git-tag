#!/bin/bash

# Define the tag name and commit message
TAG_NAME="v1.0.0"
COMMIT_MESSAGE="Release version ${TAG_NAME}"

# Create the tag and push it to the remote repository
git tag -a "${TAG_NAME}" -m "${COMMIT_MESSAGE}"
git push origin "${TAG_NAME}"
