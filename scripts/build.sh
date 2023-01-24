#!/usr/bin/env sh
set -Eeux
dart compile js
flutter build web --web-renderer html "$@"
