#!/usr/bin/env sh
set -Eeuxo pipefail
flutter build web --web-renderer html "$@"
