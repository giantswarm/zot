#!/bin/bash -x

BIN_NAME=$(basename "$0")
function help() {
	echo "Usage: $BIN_NAME"
	echo
	echo "  Requires a config file named 'subtree-cfg.ini' with at least one config section with the following structure:"
	echo "    [CONFIG_SECTION_NAME]"
	echo "    REMOTE_URL=X: the URL of the upstream repository"
	echo "    REMOTE_DIR=X: the directory in the upstream repository to extract"
	echo "    DOWN_DIR=X: the directory in the current repository to put the subtree in"
}

if [[ $# -ne 0 && $# -ne 1 ]]; then
	help
	exit 1
fi

if [[ $# -eq 1 && ($1 == "-h" || $1 == "--help") ]]; then
	help
	exit 0
fi

if [[ $# -eq 1 ]]; then
	REPO_NAME=$1
fi

declare -r CFG_FILE_NAME="subtree-cfg.ini"
# parse config options
if [[ ! -f "$CFG_FILE_NAME" ]]; then
	echo "Config file $CFG_FILE_NAME not found"
	exit 1
fi

configs=""
while read line; do
	if [[ $line =~ ^"["(.+)"]"$ ]]; then
		arrname=${BASH_REMATCH[1]}
		declare -A "$arrname"
		configs="$configs $arrname"
	elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then
		declare ${arrname}[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
	fi
done <"$CFG_FILE_NAME"

SOURCE_ALTERED=false
for CONFIG_NAME in $configs; do
	echo "Processing config section: $CONFIG_NAME"

	declare -n cfg="$CONFIG_NAME"
	REMOTE_URL=${cfg["REMOTE_URL"]}
	REMOTE_DIR=${cfg["REMOTE_DIR"]}
	DOWN_DIR=${cfg["DOWN_DIR"]}

	UPSTREAM_NAME="upstream-${CONFIG_NAME}"

	set +e
	remote_log=$(git remote show "$UPSTREAM_NAME")
	remote_status=$?
	remote_ok=false
	if [[ $remote_status -eq 0 ]]; then
		remote_url=$(echo "$remote_log" | awk '/Fetch URL/ {print $3}')
		if [[ "$remote_url" != "$REMOTE_URL" ]]; then
			echo "Remote URL mismatch: $remote_url != $REMOTE_URL"
			echo "Please remove or rename your remote, so that the name '$REMOTE_URL' is not used."
			exit 1
		fi
		remote_ok=true
		echo "Detected correct remote with upstream URL: $remote_url"
	fi

	set -e
	if [[ "$remote_ok" = false ]]; then
		echo "Adding remote $UPSTREAM_NAME"
		git remote add "$UPSTREAM_NAME" "$REMOTE_URL"
	fi

	# detect latest tags
	git fetch "$UPSTREAM_NAME" --tags
	latest_upstream_tag=$(git tag --sort=-creatordate | grep "$(git ls-remote --tags "$UPSTREAM_NAME" | cut -f3 -d"/")" | head -n 1)
	echo "Latest upstream tag in $UPSTREAM_NAME: $latest_upstream_tag"

	latest_merged_tag=$(git log | awk "/Merge '${DOWN_DIR//\//\\/}' from tag '(.+)'/{gsub(/'/, \"\", \$0);print \$5;exit}")
	if [[ -z "$latest_merged_tag" ]]; then
		echo "Could not detect the last merged tag for local directory '$DOWN_DIR'. Exiting." >&2
		exit 2
	fi
	echo "Latest merged tag: $latest_merged_tag"

	# TODO: detect/configure squash

	# run the script with the latest tag
	git checkout -b upstream-sync
	echo "Running git-subtree-update.sh with the latest tag"
	SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
	set +e
	"$SCRIPT_DIR"/git-subtree-update.sh \
		-n "$CONFIG_NAME" \
		-r "$REMOTE_URL" \
		-t "$latest_upstream_tag" \
		-d "$REMOTE_DIR" \
		-l "$DOWN_DIR" \
		-m "$latest_merged_tag" \
		-g
	set -e

	if git diff-index --quiet HEAD --; then
		echo "No changes detected, continuing."
		continue
	fi

	SOURCE_ALTERED=true

	if git status --short | grep "^UU "; then
		echo "Conflicts detected, forcing merge commit."
		git add -A
		git commit --no-verify -m "Merge '$DOWN_DIR' from tag '$latest_upstream_tag'"
		git notes add -f -m "upstream sync: URL='$REMOTE_URL' SYNC_REF='$latest_upstream_tag' REMOTE_DIR='$REMOTE_DIR' DOWN_DIR='$DOWN_DIR'"
	fi

done

if [[ $SOURCE_ALTERED = false ]]; then
	echo "No changes detected, exiting."
	exit 0
fi

echo "Creating PR on GitHub"
set +e
git push origin --delete upstream-sync
set -e
git push --set-upstream origin upstream-sync
if [[ -z "$REPO_NAME" ]]; then
	REPO_NAME=$(gh repo view --json nameWithOwner -q ".nameWithOwner")
	echo "Detected repository name: $REPO_NAME"
else
	echo "Using repository name: $REPO_NAME"
fi
gh pr create --title "Automated update to tag $latest_upstream_tag" \
	--body "This PR updates the chart using git subtree to the latest tag in the upstream repository." \
	--base main \
	--head upstream-sync \
	-R "$REPO_NAME"
echo "Done"
