#!/bin/bash

source subtree-cfg.sh

# check if remote tag newer then the most recent local tag is available

remote_log=$(git remote show upstream)
remote_status=$?
remote_ok=false
if [[ $remote_status -eq 0 ]]; then
	remote_url=$(echo "$remote_log" | awk '/Fetch URL/ {print $3}')
	if [[ "$remote_url" != "$REMOTE_URL" ]]; then
		echo "Remote URL mismatch: $remote_url != $REMOTE_URL"
		echo "Please remove or rename your remote, so that the name 'upstream' is not used."
		exit 1
	fi
	remote_ok=true
	echo "Detected correct remote upstream URL: $remote_url"
fi

if ! $remote_ok; then
	echo "Adding remote upstream"
	git remote add upstream $REMOTE_URL
fi

git checkout -b upstream-sync
git fetch upstream --tags
latest_upstream_tag=$(git tag --sort=-creatordate | grep "$(git ls-remote --tags upstream | cut -f3 -d"/")" | head -n 1)
echo "Latest upstream tag: $latest_upstream_tag"

# run the script with the latest tag
echo "Running git-subtree-update.sh with the latest tag"
./git-subtree-update.sh "$latest_upstream_tag"
if git diff-index --quiet HEAD --; then
	echo "No changes detected, exiting."
	exit 0
fi

# echo "Creating PR on GitHub"
# gh pr create --title "Automated update to tag $latest_upstream_tag" \
# 	--body "This PR updates the chart using git subtree to the latest tag in the upstream repository." \
# 	--base main \
# 	--head upstream-sync
# echo "Done"
