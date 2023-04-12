#!/bin/bash

# Get the previous tag name
PREVIOUS_TAG=$(git describe --tags --abbrev=0)

# Split the previous tag into its components
IFS='-' read -ra PREVIOUS_TAG_COMPONENTS <<< "${PREVIOUS_TAG}"

# Extract the version number from the previous tag
PREVIOUS_VERSION="${PREVIOUS_TAG_COMPONENTS[2]}"

# Split the previous version number into its components
IFS='.' read -ra PREVIOUS_VERSION_COMPONENTS <<< "${PREVIOUS_VERSION}"

# Increment the last component of the previous version number to get the new version number
NEW_VERSION="${PREVIOUS_VERSION_COMPONENTS[0]}.${PREVIOUS_VERSION_COMPONENTS[1]}.$((PREVIOUS_VERSION_COMPONENTS[2]+1))"

# Define the new tag name
NEW_TAG="TMS-CLIENT-V${NEW_VERSION}-$(date +%Y-%m-%d)"

# Define the commit message
COMMIT_MESSAGE="Release version ${NEW_TAG}"

# Create the tag and push it to the remote repository
git tag -a "${NEW_TAG}" -m "${COMMIT_MESSAGE}"
git push origin "${NEW_TAG}"
