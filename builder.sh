#!/bin/bash

if [ -z "$JENKINS_PARSER" ]; then
    echo "The Jenkins parser isn't defined, bruh. Check your privilege."
    exit 1
fi

if [ -z "$HUE_UPDATER" ]; then
    echo "The Hue updater isn't defined, bruh. Check your privilege."
    exit 1
fi

readLightStateUrlFromConfigFile () {
    local configFile="$1"

    cat "$configFile" | jq -r '.hueLightStateUrl'
}

readJenkinsUrlFromConfigFile () {
    local configFile="$1"
    
    cat "$configFile" | jq -r '.jenkinsViewUrl'
}

dieIfConfigFileDoesNotExist () {
    local configFile="$1"

    if [ ! -f $configFile ]; then
        echo "Bruh, that file doesn't exist."
        exit 1
    fi
}

verifyConfigFile () {
    local configFile="$1"
    local returnValue=0

    dieIfConfigFileDoesNotExist $configFile

    (cat $configFile | jq -re '.jenkinsViewUrl' >/dev/null 2>&1)
    if [ $? -ne 0 ]; then
        echo "Your config lacks a 'jenkinsViewUrl' value."
        returnValue=1
    fi
    
    (cat $configFile | jq -re '.hueLightStateUrl' >/dev/null 2>&1)
    if [ $? -ne 0 ]; then
        echo "Your config lacks a 'hueLightStateUrl' value."
        returnValue=1
    fi

    exit $returnValue
}

runBuilder () {
    local configFile="$1"

    dieIfConfigFileDoesNotExist $configFile

    local jenkinsViewUrl=$(readJenkinsUrlFromConfigFile "$configFile")
    local hueLightStateUrl=$(readLightStateUrlFromConfigFile "$configFile")
    local jenkinsViewState=$($JENKINS_PARSER "$jenkinsViewUrl")

    $HUE_UPDATER $jenkinsViewState "$hueLightStateUrl"
}

main () {
    while test $# -gt 0; do
        case "$1" in
            --verify)
                shift
                verifyConfigFile "$1"
                ;;
            *)
                runBuilder $*
                shift
                ;;
        esac
    done
}

main $*
