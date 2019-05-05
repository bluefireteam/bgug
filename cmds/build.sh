#!/bin/bash -e

flutter pub get
flutter packages pub run build_runner build
