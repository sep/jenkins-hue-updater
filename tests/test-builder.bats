#!/usr/bin/env bats

builder="./builder.sh"

JENKINS_PARSER="./tests/stub-jenkins_parser.sh"
export JENKINS_PARSER

HUE_UPDATER="./tests/stub-hue_updater.sh"
export HUE_UPDATER

@test "should call jenkins parser with correct URL" {
    run $builder "./fixtures/sample-config.json"

    [ "$output" == "Updating Hue with: GOOD http://example.com/hue/lights/1/state" ]
}

@test "should notify if jenkins parser script not given" {
    unset JENKINS_PARSER

    run $builder "./fixtures/sample-config.json"

    [ "$status" -eq 1 ]
    [ "$output" == "The Jenkins parser isn't defined, bruh. Check your privilege." ]
}

@test "should notify if hue updater script not given" {
    unset HUE_UPDATER

    run $builder "./fixtures/sample-config.json"

    [ "$status" -eq 1 ]
    [ "$output" == "The Hue updater isn't defined, bruh. Check your privilege." ]
}

@test "should notify user that config file lacks jenkinsViewUrl" {
    run $builder --verify "./fixtures/sample-config-missing-jenkinsViewUrl.json"

    [ "$status" -eq 1 ]
    [ "$output" == "Your config lacks a 'jenkinsViewUrl' value." ]
}

@test "should notify user that config file lacks hueLightStateUrl" {
    run $builder --verify "./fixtures/sample-config-missing-hueLightStateUrl.json"

    [ "$status" -eq 1 ]
    [ "$output" == "Your config lacks a 'hueLightStateUrl' value." ]
}

@test "should notify user that config file lacks hueLightStateUrl and jenkinsViewUrl" {
    run $builder --verify "./fixtures/sample-config-missing-hueLightStateUrl-and-jenkinsViewUrl.json"

    [ "$status" -eq 1 ]
    [ "${lines[0]}" == "Your config lacks a 'jenkinsViewUrl' value." ]
    [ "${lines[1]}" == "Your config lacks a 'hueLightStateUrl' value." ]
}

@test "should notify user that config file is okay" {
    run $builder --verify "./fixtures/sample-config.json"

    [ "$status" -eq 0 ]
}

@test "should notify user that config file does not exist on verify" {
    run $builder --verify "./missing-config-file.json"

    [ "$status" -eq 1 ]
    [ "$output" == "Bruh, that file doesn't exist." ]
}

@test "should notify user that config file does not exist" {
    run $builder "./missing-config-file.json"

    [ "$status" -eq 1 ]
    [ "$output" == "Bruh, that file doesn't exist." ]
}

@test "should send color, saturation, and brightness optiosn to hue updater" {
    run $builder "./fixtures/sample-config-fully-loaded.json"

    [ "$output" == "Updating Hue with: --bad-color 123 --good-color 234 --building-color 345 --bad-and-building-color 456 --unstable-color 567 --saturation 111 --brightness 222 GOOD http://example.com/hue/lights/1/state" ]
}
