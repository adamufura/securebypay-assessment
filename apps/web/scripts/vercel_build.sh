#!/usr/bin/env bash
set -euo pipefail

FLUTTER_DIR="${HOME}/flutter"
API_BASE_URL="${API_BASE_URL:-https://securebypay-assessment.vercel.app/api}"

if [ ! -x "${FLUTTER_DIR}/bin/flutter" ]; then
  echo "Installing Flutter SDK..."
  rm -rf "${FLUTTER_DIR}"
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

flutter config --no-analytics
flutter config --enable-web
flutter pub get
flutter build web --release --dart-define="API_BASE_URL=${API_BASE_URL}"
