#!/bin/sh -l

set -e

# Key scan for github.com
ssh-keyscan github.com > /root/.ssh/known_hosts

# Set ssh key for subtree
echo "${INPUT_DEPLOY_KEY}" >> /root/.ssh/subtree
chmod 0600 /root/.ssh/subtree

# Generate sha256 of the downstream repo name
# SPLIT_DIR=$(echo -n "${INPUT_REPO}" | sha256sum)
# SPLIT_DIR="${SPLIT_DIR::-3}"

# Get subtree repository into split directory
# git init --bare "${SPLIT_DIR}"

# Create the subtree split branch
# git subtree split --prefix="${INPUT_PATH}" -b split

# Resolve downstream branch.
# If not set then use the event github ref, if the ref isn't set default to master.
if [ "$INPUT_BRANCH" == "" ]; then
	# if [ -z "$GITHUB_REF" ] || [ "$GITHUB_REF" == "" ]; then
		PULL_BRANCH="master"
	else
		PULL_BRANCH="$INPUT_BRANCH"
	# fi
fi

# Check for merge message
if [ "$INPUT_MESSAGE" == "" ]; then
	PULL_MESSAGE='-m "Update dependency of subtree"'
else
	PULL_MESSAGE="$INPUT_MESSAGE"
fi

# Sync subtree directory
echo "----------------git subtree $INPUT_ACTION----------------------"
# ssh -i /root/.ssh/subtree git@github.com
git log --oneline
echo git subtree pull --prefix="$INPUT_PATH" git@github.com:"$INPUT_REPO".git "$PULL_BRANCH" --squash "$PULL_MESSAGE"
git subtree pull --prefix="$INPUT_PATH" git@github.com:"$INPUT_REPO".git "$PULL_BRANCH" --squash "$PULL_MESSAGE"
# git push -u origin master

