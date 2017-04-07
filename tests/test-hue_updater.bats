#!/usr/bin/env bats

lightStateUrl="http://example.com/lights/1/state"
export lightStateUrl

hue_updater="./hue_updater.sh"

function curl() {
    echo "Calling curl with $*"
}
export -f curl

@test "should freak out if passed invalid state" {
    run $hue_updater MOOCOW

    [ "$output" == "Invalid state. Try again, buddy." ]
    [ "$status" -eq 1 ]
}

@test "should update hue with green on GOOD" {
    run $hue_updater GOOD "$lightStateUrl"

    [ "$output" == "Calling curl with -X PUT -d {\"hue\":25717,\"bri\":255,\"sat\":255} http://example.com/lights/1/state" ]
}

@test "should update hue with red on BAD" {
    run $hue_updater BAD "$lightStateUrl"

    [ "$output" == "Calling curl with -X PUT -d {\"hue\":0,\"bri\":255,\"sat\":255} http://example.com/lights/1/state" ]
}

@test "should update hue to custom color on BAD" {
    run $hue_updater --bad-color 12345 BAD "$lightStateUrl"

    [ "$output" == "Calling curl with -X PUT -d {\"hue\":12345,\"bri\":255,\"sat\":255} http://example.com/lights/1/state" ]
}

@test "should update hue to custom color on GOOD" {
    run $hue_updater --good-color 12345 GOOD "$lightStateUrl"

    [ "$output" == "Calling curl with -X PUT -d {\"hue\":12345,\"bri\":255,\"sat\":255} http://example.com/lights/1/state" ]
}

@test "should update hue to custom color on BUILDING" {
    run $hue_updater --building-color 12345 BUILDING "$lightStateUrl"

    [ "$output" == "Calling curl with -X PUT -d {\"hue\":12345,\"bri\":255,\"sat\":255} http://example.com/lights/1/state" ]
}

@test "should update hue to custom color on BAD_AND_BUILDING" {
    run $hue_updater --bad-and-building-color 12345 BAD_AND_BUILDING "$lightStateUrl"

    [ "$output" == "Calling curl with -X PUT -d {\"hue\":12345,\"bri\":255,\"sat\":255} http://example.com/lights/1/state" ]
}

@test "should update hue to custom color on UNSTABLE" {
    run $hue_updater --unstable-color 12345 UNSTABLE "$lightStateUrl"

    [ "$output" == "Calling curl with -X PUT -d {\"hue\":12345,\"bri\":255,\"sat\":255} http://example.com/lights/1/state" ]
}

@test "should update saturation to custom value" {
    run $hue_updater --saturation 111 BAD "$lightStateUrl"

    [ "$output" == "Calling curl with -X PUT -d {\"hue\":0,\"bri\":255,\"sat\":111} http://example.com/lights/1/state" ]
}

@test "should update brightness to custom value" {
    run $hue_updater --brightness 111 BAD "$lightStateUrl"

    [ "$output" == "Calling curl with -X PUT -d {\"hue\":0,\"bri\":111,\"sat\":255} http://example.com/lights/1/state" ]
}
