#!/bin/bash -e

flutter packages pub run build_runner build --delete-conflicting-outputs

flutter build appbundle # builds 64-bit compatible artifact
echo 'Built at build/app/outputs/bundle/release/app.aab'
