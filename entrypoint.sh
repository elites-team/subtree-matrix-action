#!/bin/sh -l

# set -e

# Key scan for github.com
ssh-keyscan github.com > /root/.ssh/known_hosts

# Set ssh key for subtree
echo "${INPUT_DEPLOY_KEY}" >> /root/.ssh/subtree
chmod 0600 /root/.ssh/subtree

eval `ssh-agent`
ssh-add /root/.ssh/subtree

git config user.email "$GITHUB_RUN_NUMBER+github-actions[bot]@users.noreply.github.com"
git config user.name "github-actions[bot]"

# # -------------for loop start---------------
# if [ "$INPUT_BRANCH" == "" ]; then
#   PULL_BRANCH="master"
# else
#   PULL_BRANCH="$INPUT_BRANCH"
# fi

# # Check for merge message
# if [ "$INPUT_MESSAGE" == "" ]; then
# 	PULL_MESSAGE="-m 'Update dependency of subtree'"
# else
# 	PULL_MESSAGE="-m '$INPUT_MESSAGE'"
# fi

# # Sync subtree directory
# before_sha=`git rev-parse --short HEAD`
# git subtree pull --prefix="$INPUT_PATH" git@github.com:"$INPUT_REPO".git "$PULL_BRANCH" --squash "${PULL_MESSAGE}"
# git subtree push --prefix="$INPUT_PATH" git@github.com:"$INPUT_REPO".git "$PULL_BRANCH"
# after_sha=`git rev-parse --short HEAD`
# if [ ! $before_sha = $after_sha ]; then
#   git pull origin $GITHUB_REF
#   git push origin $GITHUB_REF
# fi
# # ------------------for loop end--------------------
echo "-----matrix action------"
echo $INPUT_MATRIX
# json作成にはヒアドキュメントを使う
# INPUT_MATRIX=$(cat << EOS
# [
#   {
#     "path": "prefix/path",
#     "repo": "owner/repository",
#     "branch": "master"
#   },
#   {
#     "path": "prefix/path",
#     "repo": "owner/repository",
#     "branch": "master"
#   }
# ]
# EOS
# )

# JSON解析にはjqを使う
# echo "-r '.[0].path'"
# echo $INPUT_MATRIX | jq -r '.[0].path'
# echo
# echo "-r '.[0].repo'"
# echo $INPUT_MATRIX | jq -r '.[0].repo'
# echo
# echo "-r '.[0].branch'"
# echo $INPUT_MATRIX | jq -r '.[0].branch'
# echo
# echo "-r '. | length'"
# echo $INPUT_MATRIX | jq -r '. | length'

for base in $(echo "${INPUT_MATRIX}" | jq -r '.[] | @base64'); do
  matrix=$(echo ${base} | base64 -d )
  echo ${matrix}
  INPUT_PATH=$(echo ${matrix} | jq -r '.path')
  echo $INPUT_PATH
  INPUT_REPO=$(echo ${matrix} | jq -r '.repo')
  echo $INPUT_REPO
  INOUT_BRANCH=$(echo ${matrix} | jq -r '.branch')
  echo $INOUT_BRANCH
  # -------------for loop start---------------
  if [ "$INPUT_BRANCH" == "" ]; then
    PULL_BRANCH="master"
  else
    PULL_BRANCH="$INPUT_BRANCH"
  fi

  # Check for merge message
  if [ "$INPUT_MESSAGE" == "" ]; then
    PULL_MESSAGE="-m 'Update dependency of subtree'"
  else
    PULL_MESSAGE="-m '$INPUT_MESSAGE'"
  fi

  # Sync subtree directory
  before_sha=`git rev-parse --short HEAD`
  git subtree pull --prefix="$INPUT_PATH" git@github.com:"$INPUT_REPO".git "$PULL_BRANCH" --squash "${PULL_MESSAGE}"
  git subtree push --prefix="$INPUT_PATH" git@github.com:"$INPUT_REPO".git "$PULL_BRANCH"
  after_sha=`git rev-parse --short HEAD`
  if [ ! $before_sha = $after_sha ]; then
    git pull origin $GITHUB_REF
    git push origin $GITHUB_REF
  fi
  # ------------------for loop end--------------------
done
