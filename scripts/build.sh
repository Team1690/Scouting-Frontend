#!/usr/bin/env sh
set -Eeux
flutter build web --web-renderer html "$@"
