#!/bin/bash

# Function to prompt the user to select a repository to tag
select_repository() {
  echo "Which repository do you want to tag?"
  echo "1. CLIENT"
  echo "2. SERVICE"
  read REPO_NUM

  if ! echo "$REPO_NUM" | grep -q "^[1-2]$"; then
    echo "Error: Invalid input. Please enter 1 or 2."
    exit 1
  fi

  if [ "$REPO_NUM" -eq 1 ]; then
    REPO_NAME="CLIENT"
  elif [ "$REPO_NUM" -eq 2 ]; then
    REPO_NAME="SERVICE"
  fi

  echo "Selected repository: $REPO_NAME"
}

# Function to create an initial tag with version 1.0.0
create_initial_tag() {
  NEW_TAG="TMS-$REPO_NAME-1.0.0-$(date +%F)"
  COMMIT_MESSAGE="PROD RELEASE $(date +%F)"
  echo "Created initial tag: $NEW_TAG"
}

# Function to get the latest tag and extract the version number and date
get_latest_tag_info() {
  echo "Fetching from origin"
  git pull
  git pull --tags --force

  LATEST_TAG=$(git tag -l --sort=-creatordate "TMS-$REPO_NAME-[0-9]*.[0-9]*.[0-9]*-*" | head -n 1)
  DATE=$(date +%F)

  if [ -z "$LATEST_TAG" ]; then
    echo "No matching tags found."
    IS_INITIAL="true"
  else
    VERSION=${LATEST_TAG##TMS-$REPO_NAME-}
  fi
}

# Function to prompt the user for the release type and increment the version number accordingly
increment_version_number() {
  echo "What type of release is this?"
  echo "1. Major release"
  echo "2. Minor release"
  echo "3. Patch release"
  echo "4. Test release"
  read RELEASE_TYPE

  case $RELEASE_TYPE in
    1)
      VERSION=$(echo $VERSION | awk -F. '{$1 = $1 + 1; $2 = 0; $3 = 0;} 1' OFS=.)
      NEW_TAG="TMS-$REPO_NAME-$VERSION-$DATE"
      COMMIT_MESSAGE="PROD RELEASE $DATE"
      ;;
    2)
      VERSION=$(echo $VERSION | awk -F. '{$2 = $2 + 1; $3 = 0;} 1' OFS=.)
      NEW_TAG="TMS-$REPO_NAME-$VERSION-$DATE"
      COMMIT_MESSAGE="PROD RELEASE $DATE"
      ;;
    3)
      VERSION=$(echo $VERSION | awk -F. '{$3 = $3 + 1;} 1' OFS=.)
      NEW_TAG="TMS-$REPO_NAME-$VERSION-$DATE"
      COMMIT_MESSAGE="PROD RELEASE $DATE"
      ;;
    4)
      NEW_TAG="test"
      COMMIT_MESSAGE="TEST PROD RELEASE $DATE"
      ;;
    *)
      echo "Error: Invalid release type."
      exit 1
      ;;
  esac

}

# Function to tag the repository and push the tag
tag_repository() {
  git tag -a $NEW_TAG -m "$COMMIT_MESSAGE"

  if [ $? -ne 0 ]; then
    echo "Error: Failed to create tag."
    exit 1
  fi

  git push origin $NEW_TAG

  if [ $? -ne 0 ]; then
    echo "Error: Failed to push tag. Deleting the tag $NEW_TAG."
    git tag -d $NEW_TAG
    exit 1
  fi

  GIT_REV=$(git rev-parse $NEW_TAG)
  echo "Tagged $NEW_TAG with hash id $GIT_REV and pushed to origin."
  
  if [ "$RELEASE_TYPE" != "4" ]; then
    git tag latest $GIT_REV --force
    git push origin latest --force
    echo "Pushed latest tag to origin."
  fi
}

# Main function
main() {
  select_repository
  get_latest_tag_info

  if [ "$IS_INITIAL" = "true" ]; then
    create_initial_tag
  else
    increment_version_number
  fi
  
  tag_repository

}

# Call the main function
main