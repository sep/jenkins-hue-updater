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
    curlOutput=$( curl -u "$token" --header "Content-Type: application/json" "$jenkinsViewUrl" 2>/dev/null )

    if [[ $? -ne 0 ]]; then
		echo -n "ERROR"
    else
		echo "$curlOutput"
    fi
}

getTheColorsFromJson () {
    local json="$1"
    jqOutput=$( echo "$json" | jq '.status' 2> /dev/null )

    if [[ $? -ne 0 ]]; then
		echo -n "ERROR"
    else
		local status=$( echo "$json" | jq '.status' | tr -d '\r' )
		local result=$( echo "$json" | jq '.result' | tr -d '\r' )
	
		if [ "$status" != "\"completed\"" ]; then
			echo -n "BUILDING"
		else
			if [[ "$result" == "\"succeeded\"" ]]; then
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

	echo "$jenkinsViewUrl:$token" > /tmp/json.json
    local json=$(getTheJson "$jenkinsViewUrl" ":$token")

    if [[ $json == "ERROR" ]]; then
		echo "JENKINS_DOWN"
    else
		local colors=$(getTheColorsFromJson "$json")

		if [[ $colors == "ERROR" ]]; then
			echo "JENKINS_DOWN"
		else
			echo "$colors"
		fi
    fi
}

main "$1" "$2"
