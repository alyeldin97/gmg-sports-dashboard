#!/bin/bash
# GMG Sports — Runs the admin dashboard on Chrome
set -e

echo "======================================================"
echo "  GMG Sports — Dashboard Setup"
echo "======================================================"

cd "$(dirname "$0")"

echo ""
echo "── Flutter pub get ─────────────────────────────────"
flutter pub get

echo ""
echo "── Running GMG Dashboard on Chrome (port 8081) ─────"
echo "   Admin:    admin@gmgsports.com  /  Admin@123"
echo "   Press 'q' to quit, 'r' to hot-reload"
flutter run -d chrome --web-port 8081
