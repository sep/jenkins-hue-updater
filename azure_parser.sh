#!/bin/bash

hash curl 2>/dev/null || {
    echo >&2 "Please install 'curl', buddy"
    exit 1
}

hash jq 2>/dev/null || {
    echo >&2 "Please install 'jq', buddy"
    exit 1
}

getTheJson () {
    jenkinsViewUrl="$1"
	token="$2"
	latestBuildUrl=$( curl -u "$token" "$jenkinsViewUrl" | jq -r '.value[0]._links.self.href' | tr -d '\r\n' )
	
    curlOutput=$( curl -u "$token" --header "Content-Type: application/json" "$latestBuildUrl" 2>/dev/null )

    if [[ $? -ne 0 ]]; then
		echo -n "ERROR"
    else
		echo "$curlOutput"
    fi
}

getTheColorsFromJson () {
    local json="$1"
	agentName="$2"
	jqProgram=".environments[] | select(.name == \"$agentName\") | .status"
    jqOutput=$( echo "$json" | jq -r "$jqProgram" | tr -d '\r\n' )

    if [[ $? -ne 0 ]]; then
		echo -n "ERROR"
    else
		local status=$( echo "$json" | jq -r "$jqProgram" | tr -d '\r\n' )
	
		if [ "$status" == "inProgress" ]; then
			echo -n "BUILDING"
		else
			if [[ "$status" == "succeeded" ]]; then
				echo -n "GOOD"
			else
				echo -n "BAD"
			fi
		fi
    fi
}

main () {
    local jenkinsViewUrl="$1"
	local token="$2"
	local agentName="$3"

    local json=$(getTheJson "$jenkinsViewUrl" ":$token")

    if [[ $json == "ERROR" ]]; then
		echo "JENKINS_DOWN"
    else
		local colors=$(getTheColorsFromJson "$json" "$agentName")

		if [[ $colors == "ERROR" ]]; then
			echo "JENKINS_DOWN"
		else
			echo "$colors"
		fi
    fi
}

main "$1" "$2" "$3"
