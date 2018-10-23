#!/bin/bash

hash curl 2>/dev/null || {
    echo >&2 "Please install 'curl', buddy"
    exit 1
}

GOOD=25717
BAD=0
BAD_AND_BUILDING=46920
BUILDING=46920
UNSTABLE=12750

SATURATION=255
BRIGHTNESS=255

dieIfStateIsInvalid () {
    local state="$1"
    
    if [[ "-GOOD-BAD-BAD_AND_BUILDING-BUILDING-UNSTABLE-JENKINS_DOWN-" != *"-${state}-"* ]]; then
        echo "Invalid state. Try again, buddy."
        exit 1
    fi
}

updateHueState () {
    local state="$1"
    dieIfStateIsInvalid "$state"

    local lightStateUrl="$2"
    local jsonData="{\"hue\":${!1},\"on\":true,\"bri\":${BRIGHTNESS},\"sat\":${SATURATION}}"
    
    if [ $state == "JENKINS_DOWN" ]; then
	jsonData="{\"on\":false}"
    fi
    
    curl -X PUT -d "$jsonData" "$lightStateUrl"
}

main () {
    while test $# -gt 0; do
        case "$1" in
            --bad-color)
                shift
                BAD="$1"
                shift
                ;;
            --good-color)
                shift
                GOOD="$1"
                shift
                ;;
            --building-color)
                shift
                BUILDING="$1"
                shift
                ;;
            --bad-and-building-color)
                shift
                BAD_AND_BUILDING="$1"
                shift
                ;;
            --unstable-color)
                shift
                UNSTABLE="$1"
                shift
                ;;
            --saturation)
                shift
                SATURATION="$1"
                shift
                ;;
            --brightness)
                shift
                BRIGHTNESS="$1"
                shift
                ;;
            *)
                updateHueState $*
                exit 0
                ;;
        esac
    done
}

main $*
