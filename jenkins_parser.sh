#!/bin/bash

hash curl 2>/dev/null || {
    echo >&2 "Please install 'curl', buddy"
    exit 1
}

hash jq 2>/dev/null || {
    echo >&2 "Please install 'jq', buddy"
    exit 1
}

array_any () {
    local match="$1"; shift
    local items=( "$@" )

    for item in "${items[@]}"; do
        if [ "$item" == "$match" ]; then
            return 0
        fi
    done

    return 1
}

array_any_match () {
    local match="$1"; shift
    local items=( "$@" )

    for item in "${items[@]}"; do
        if [[ "$item" == *"$match"* ]]; then
            return 0
        fi
    done

    return 1
}

areAnyJobsFailing () {
    local colors=( "$@" )

    array_any "\"red\"" "${colors[@]}"
}

areAnyJobsBuilding () {
    local colors=( "$@" )

    array_any_match "_anim" "${colors[@]}"
}

areAnyJobsUnstable () {
    local colors=( "$@" )

    array_any_match "unstable" "${colors[@]}"
}

getTheJson () {
    local jenkinsViewUrl="$1"

    curl "$jenkinsViewUrl" 2>/dev/null
}

getTheColorsFromJson () {
    local json="$1"

    echo "$json" | jq '.jobs[].color'
}

getTheResultFromColorList () {
    local colors=( "$@" )

    if $(areAnyJobsFailing "${colors[@]}"); then
        if ! $(areAnyJobsBuilding "${colors[@]}"); then
            echo "BAD"
        else
            echo "BAD_AND_BUILDING"
        fi
    else
        if $(areAnyJobsBuilding "${colors[@]}"); then
            echo "BUILDING"
        elif $(areAnyJobsUnstable "${colors[@]}"); then
            echo "UNSTABLE"
        else
            echo "GOOD"
        fi
    fi
}

main () {
    local jenkinsViewUrl="$1"
    local json=$(getTheJson "$jenkinsViewUrl")
    local colors=$(getTheColorsFromJson "$json")

    echo "$(getTheResultFromColorList $colors)"
}

main "$1"
