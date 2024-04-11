#!/bin/bash

FILE=Chart.yaml
FILE_PATH=helm/zot/"$FILE"
OURS=/tmp/"$FILE".ours
THEIRS=/tmp/"$FILE".theirs

echo "Patching $FILE with upstream versions info"
git show :2:"$FILE_PATH" >"$OURS"
git show :3:"$FILE_PATH" >"$THEIRS"

yq ".appVersion = load(\"$THEIRS\").appVersion" -i "$OURS"
yq ".version = load(\"$THEIRS\").version" -i "$OURS"
yq ".upstreamChartVersion = load(\"$THEIRS\").version" -i "$OURS"

cp "$OURS" "$FILE_PATH"
git add "$FILE_PATH"
