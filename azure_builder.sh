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

readAzureTokenFromConfigFile () {
	local configFile="$1"

	cat "$configFile" | jq -r '.azureToken'
}

readAgentNameFromConfigFile () {
	local configFile="$1"

	cat "$configFile" | jq -r '.agentName' | tr -d '\r'
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

buildArgumentStringForHueUpdater () {
    local configFile="$1"

    argumentString=""

    local badColor=$(cat $configFile | jq -re '.colors.bad')
    if [ $badColor != "null" ]; then
        argumentString=$(echo "$argumentString --bad-color $badColor")
    fi

    local goodColor=$(cat $configFile | jq -re '.colors.good')
    if [ $goodColor != "null" ]; then
        argumentString=$(echo "$argumentString --good-color $goodColor")
    fi

    local buildingColor=$(cat $configFile | jq -re '.colors.building')
    if [ $buildingColor != "null" ]; then
        argumentString=$(echo "$argumentString --building-color $buildingColor")
    fi

    local badAndBuildingColor=$(cat $configFile | jq -re '.colors.badAndBuilding')
    if [ $badAndBuildingColor != "null" ]; then
        argumentString=$(echo "$argumentString --bad-and-building-color $badAndBuildingColor")
    fi

    local unstableColor=$(cat $configFile | jq -re '.colors.unstable')
    if [ $unstableColor != "null" ]; then
        argumentString=$(echo "$argumentString --unstable-color $unstableColor")
    fi

    local saturation=$(cat $configFile | jq -re '.saturation')
    if [ $saturation != "null" ]; then
        argumentString=$(echo "$argumentString --saturation $saturation")
    fi

    local brightness=$(cat $configFile | jq -re '.brightness')
    if [ $brightness != "null" ]; then
        argumentString=$(echo "$argumentString --brightness $brightness")
    fi

    echo "$argumentString"
}

runBuilder () {
    local configFile="$1"

    dieIfConfigFileDoesNotExist $configFile

    local jenkinsViewUrl=$(readJenkinsUrlFromConfigFile "$configFile")
    local hueLightStateUrl=$(readLightStateUrlFromConfigFile "$configFile")
	local azureToken=$(readAzureTokenFromConfigFile "$configFile")
	local agentName=$(readAgentNameFromConfigFile "$configFile")
    local jenkinsViewState=$($JENKINS_PARSER "$jenkinsViewUrl" "$azureToken" "$agentName")
    local argumentString=$(buildArgumentStringForHueUpdater "$configFile")

    $HUE_UPDATER $argumentString $jenkinsViewState "$hueLightStateUrl"
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
