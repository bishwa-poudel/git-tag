#!/bin/bash

# Get the previous tag name
PREVIOUS_TAG=$(git describe --tags --abbrev=0) || { echo "Error: could not get previous tag name" ; exit 1; }

# Split the previous tag into its components
IFS='-' read -ra PREVIOUS_TAG_COMPONENTS <<< "${PREVIOUS_TAG}" || { echo "Error: could not split previous tag name into components" ; exit 1; }

# Extract the version number from the previous tag
PREVIOUS_VERSION="${PREVIOUS_TAG_COMPONENTS[2]}" || { echo "Error: could not extract version number from previous tag name" ; exit 1; }

# Split the previous version number into its components
IFS='.' read -ra PREVIOUS_VERSION_COMPONENTS <<< "${PREVIOUS_VERSION}" || { echo "Error: could not split previous version number into components" ; exit 1; }

# Increment the last component of the previous version number to get the new version number
NEW_VERSION="${PREVIOUS_VERSION_COMPONENTS[0]}.${PREVIOUS_VERSION_COMPONENTS[1]}.$((PREVIOUS_VERSION_COMPONENTS[2]+1))" || { echo "Error: could not increment previous version number" ; exit 1; }

# Define the new tag name
NEW_TAG="TMS-CLIENT-V${NEW_VERSION}-$(date +%Y-%m-%d)" || { echo "Error: could not construct new tag name" ; exit 1; }

# Define the commit message
COMMIT_MESSAGE="Release version ${NEW_TAG}"

# Create the tag and push it to the remote repository
git tag -a "${NEW_TAG}" -m "${COMMIT_MESSAGE}" || { echo "Error: could not create new tag" ; exit 1; }
git push origin "${NEW_TAG}" || { echo "Error: could not push new tag to remote repository" ; exit 1; }

# Print success message
echo "Successfully created and pushed new tag: ${NEW_TAG}"
