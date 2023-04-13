#!/bin/bash

# Function to prompt the user to select a repository to tag
select_repository() {
  echo -e "\e[32mWhich repository do you want to tag?\e[0m"
  echo -e "1. \e[36mCLIENT\e[0m"
  echo -e "2. \e[36mSERVICE\e[0m"
  read REPO_NUM

  if ! echo "$REPO_NUM" | grep -q "^[1-2]$"; then
    echo -e "\e[31mError: Invalid input. Please enter 1 or 2.\e[0m"
    exit 1
  fi

  if [ "$REPO_NUM" -eq 1 ]; then
    REPO_NAME="CLIENT"
  elif [ "$REPO_NUM" -eq 2 ]; then
    REPO_NAME="SERVICE"
  fi

  echo -e "Selected repository: \e[36m$REPO_NAME\e[0m"
}

# Function to create an initial tag with version 1.0.0
create_initial_tag() {
  NEW_TAG="TMS-$REPO_NAME-1.0.0-$(date +%F)"
  COMMIT_MESSAGE="PROD RELEASE $(date +%F)"
  echo -e "Created initial tag: \e[32m$NEW_TAG\e[0m"
}

# Function to get the latest tag and extract the version number and date
get_latest_tag_info() {
  echo -e "\e[34mFetching from origin\e[0m"
  git pull > /dev/null 2>&1
  git pull --tags --force > /dev/null 2>&1

  LATEST_TAG=$(git tag -l --sort=-creatordate "TMS-$REPO_NAME-[0-9]*.[0-9]*.[0-9]*-*" | head -n 1)
  DATE=$(date +%F)

  if [ -z "$LATEST_TAG" ]; then
    echo -e "\e[33mNo matching tags found.\e[0m"
    IS_INITIAL="true"
  else
    VERSION=${LATEST_TAG##TMS-$REPO_NAME-}
  fi
}

# Function to prompt the user for the release type and increment the version number accordingly
increment_version_number() {
  echo -e "\e[32mWhat type of release is this?\e[0m"
  echo -e "1. \e[36mMajor release\e[0m"
  echo -e "2. \e[36mMinor release\e[0m"
  echo -e "3. \e[36mPatch release\e[0m"
  echo -e "4. \e[36mTest release\e[0m"
  read $RELEASE_TYPE

  if ! echo "$RELEASE_TYPE" | grep -q "^[1-4]$"; then
    echo -e "\e[31mError: Invalid input.\e[0m"
    exit 1
  fi

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
      echo -e "\e[31mError: Invalid release type.\e[0m"
      exit 1
      ;;
  esac

}

# Function to tag the repository and push the tag
tag_repository() {
  git tag -a $NEW_TAG -m "$COMMIT_MESSAGE" > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    echo -e "\e[31mError: Failed to create tag.\e[0m"
    exit 1
  fi

  git push origin $NEW_TAG > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    echo -e "\e[31mError: Failed to push tag. Deleting the tag $NEW_TAG.\e[0m"
    git tag -d $NEW_TAG
    exit 1
  fi

  GIT_REV=$(git rev-parse $NEW_TAG)
  echo -e "Tagged \e[32m$NEW_TAG\e[0m with hash id \e[36m$GIT_REV\e[0m and pushed to origin."
  
  if [ "$RELEASE_TYPE" != "4" ]; then
    git tag latest $GIT_REV --force > /dev/null 2>&1
    git push origin latest --force > /dev/null 2>&1
    echo -e "Pushed latest tag to origin."
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