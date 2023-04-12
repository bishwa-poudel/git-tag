#!/bin/bash

# Get the previous tag name
PREVIOUS_TAG=$(git describe --tags --abbrev=0)

# Split the previous tag into its components
IFS='.' read -ra PREVIOUS_TAG_COMPONENTS <<< "${PREVIOUS_TAG}"

# Increment the last component of the previous tag to get the new tag
NEW_TAG="${PREVIOUS_TAG_COMPONENTS[0]}.${PREVIOUS_TAG_COMPONENTS[1]}.$((PREVIOUS_TAG_COMPONENTS[2]+1))"

# Define the commit message
COMMIT_MESSAGE="Release version ${NEW_TAG}"

# Create the tag and push it to the remote repository
git tag -a "${NEW_TAG}" -m "${COMMIT_MESSAGE}"
git push origin "${NEW_TAG}"
