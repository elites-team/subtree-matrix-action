#!/bin/sh -l

set -e

# Key scan for github.com
ssh-keyscan github.com > /root/.ssh/known_hosts

# Set ssh key for subtree
echo "${INPUT_DEPLOY_KEY}" >> /root/.ssh/subtree
chmod 0600 /root/.ssh/subtree

eval `ssh-agent`
ssh-add /root/.ssh/subtree

git config user.email "$GITHUB_RUN_NUMBER+github-actions[bot]@users.noreply.github.com"
git config user.name "github-actions[bot]"

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
echo "----------------git subtree $INPUT_ACTION----------------------"
before_sha=`git rev-parse --short HEAD`
git subtree pull --prefix="$INPUT_PATH" git@github.com:"$INPUT_REPO".git "$PULL_BRANCH" --squash "${PULL_MESSAGE}"
after_sha=`git rev-parse --short HEAD`
if [ ! $before_sha = $after_sha ]; then
  git pull origin master
  git push origin master
fi
git log --oneline -5
