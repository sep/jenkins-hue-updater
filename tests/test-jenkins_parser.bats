#!/usr/bin/env bats

expectedUrl="http://example.com/api/json"
export expectedUrl

jenkins_parser="./jenkins_parser.sh"

@test "should respond with BAD if a single job is red" {
    function curl() {
        if [ "$1" != "$expectedUrl" ]; then
            exit 1
        fi

        cat "./fixtures/one-failure.json"
    }
    export -f curl

    run $jenkins_parser "$expectedUrl"

    [ "$output" == "BAD" ]
}

@test "should respond with GOOD if all jobs are blue" {
    function curl() {
        if [ "$1" != "$expectedUrl" ]; then
            exit 1
        fi
        
        cat "./fixtures/all-successes.json"
    }
    export -f curl

    run $jenkins_parser "$expectedUrl"

    [ "$output" == "GOOD" ]
}

@test "should respond with BAD_AND_BUILDING if one job is red and one is building" {
    function curl() {
        if [ "$1" != "$expectedUrl" ]; then
            exit 1
        fi
        
        cat "./fixtures/one-building-one-failure.json"
    }
    export -f curl

    run $jenkins_parser "$expectedUrl"

    [ "$output" == "BAD_AND_BUILDING" ]
}

@test "should respond with BUILDING if all jobs are blue and one is building" {
    function curl() {
        if [ "$1" != "$expectedUrl" ]; then
            exit 1
        fi
        
        cat "./fixtures/one-building-all-successes.json"
    }
    export -f curl

    run $jenkins_parser "$expectedUrl"

    [ "$output" == "BUILDING" ]
}

@test "should respond with UNSTABLE if all jobs are blue and one is unstable" {
    function curl() {
        if [ "$1" != "$expectedUrl" ]; then
            exit 1
        fi
        
        cat "./fixtures/one-unstable-all-successes.json"
    }
    export -f curl

    run $jenkins_parser "$expectedUrl"

    [ "$output" == "UNSTABLE" ]
}
