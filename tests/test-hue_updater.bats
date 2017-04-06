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
