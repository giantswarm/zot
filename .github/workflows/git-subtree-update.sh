#!/bin/bash -ex

source subtree-cfg.sh

function help() {
	echo "Usage: $0 REMOTE_TAG [FORCE_OPT]"
	echo "  Update the subtree from a tag in the upstream repository."
	echo "  Requires a config file named 'subtree-cfg.sh' with the following variables:"
	echo "    REMOTE_URL: the URL of the upstream repository"
	echo "    REMOTE_DIR: the directory in the upstream repository to extract"
	echo "    DOWN_DIR: the directory in the current repository to put the subtree in"
	echo "  FORCE_OPT: set to 'merge' or 'add' to force subtree operation"
}

if [[ $# -lt 1 ]]; then
	help
	exit 1
fi

REMOTE_REF=$1
UPSTREAM_NAME=upstream
ANNOTATE="(upstream-split) "
SPLIT_BRANCH_NAME=upstream-split
SPLIT_TAG_NAME=subtree-split-tag

current_branch=$(git rev-parse --abbrev-ref HEAD)

# dir name in the git logs always ends with a slash, so make sure we can grep it
if ! [[ "$DOWN_DIR" == */ ]]; then
	DOWN_DIR="$DOWN_DIR/"
fi

# check if upstream exists and add it if not
git remote | grep $UPSTREAM_NAME || git remote add $UPSTREAM_NAME $REMOTE_URL

# fetch upstream and the configured tag
git tag -d $SPLIT_TAG_NAME || true
git fetch -n upstream "$REMOTE_REF:refs/tags/$SPLIT_TAG_NAME"
git checkout subtree-split-tag

# split it
git branch -D $SPLIT_BRANCH_NAME || true
git subtree split --prefix=$REMOTE_DIR -b $SPLIT_BRANCH_NAME --annotate="$ANNOTATE"

# return to our branch
git checkout "$current_branch"

# check if there's anything to merge
last_split_commit=$(git log -n 1 --pretty=format:"%h" $SPLIT_BRANCH_NAME)
if git log --pretty=format:"%h" | grep "$last_split_commit"; then
	echo "The last commit from subtree seems to be already merged in the tree. Exiting."
	exit 0
fi

# decide merge vs add
if [[ -z "$2" ]]; then
	if git log -q | grep "Add '$DOWN_DIR' from commit" >/dev/null; then
		op="merge"
	else
		op="add"
	fi
else
	op="$2"
fi

# merge it
git subtree "$op" --prefix=$DOWN_DIR $SPLIT_BRANCH_NAME
git notes add -m "upstream sync: URL=\"$REMOTE_URL\" REF=\"$REMOTE_REF\""

echo "done"
