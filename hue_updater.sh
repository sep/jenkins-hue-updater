#!/bin/bash

hash curl 2>/dev/null || {
    echo >&2 "Please install 'curl', buddy"
    exit 1
}

if [[ "-GOOD-BAD-BAD_AND_BUILDING-BUILDING-UNSTABLE-" != *"-$1-"* ]]; then
    echo "Invalid state. Try again, buddy."
    exit 1
fi

GOOD=25717
BAD=0
BAD_AND_BUILDING=46920
BUILDING=46920
UNSTABLE=12750

main () {
    local jsonData="{\"hue\":${!1},\"bri\":255,\"sat\":255}"
    local lightStateUrl="$2"
    
    curl -X PUT -d "$jsonData" "$lightStateUrl"
}

main $*
