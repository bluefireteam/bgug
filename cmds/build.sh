#!/bin/bash -e

cd "$( dirname "${BASH_SOURCE[0]}" )/.."

flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter build apk --release
