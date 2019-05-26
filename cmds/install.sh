#!/bin/bash -e

cd "$( dirname "${BASH_SOURCE[0]}" )/.."

adb -e install -r build/app/outputs/apk/app.apk
