#!/bin/bash

set -e

versions=("600.0.0" "601.0.0" "602.0.0" "603.0.0")
for version in "${versions[@]}"; do
    echo "== Testing against swift-syntax $version =="

    swift package clean
    MACROTOOLKIT_SWIFT_SYNTAX_VERSION_OVERRIDE=$version swift build
    MACROTOOLKIT_SWIFT_SYNTAX_VERSION_OVERRIDE=$version swift test
done
