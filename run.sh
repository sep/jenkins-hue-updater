#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BUILDER="${DIR}/builder.sh"
HUE_UPDATER="${DIR}/hue_updater.sh"
JENKINS_PARSER="${DIR}/jenkins_parser.sh"

export HUE_UPDATER
export JENKINS_PARSER

BUILDER $*
