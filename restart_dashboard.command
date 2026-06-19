#!/bin/bash
echo "======================================================"
echo "  Restarting GMG Dashboard on Chrome (port 8081)"
echo "======================================================"

# Kill any existing flutter run on port 8081
lsof -ti tcp:8081 | xargs kill -9 2>/dev/null
pkill -f "flutter run.*8081" 2>/dev/null
sleep 2

cd /Users/alyeldinmuhammad/Desktop/gmg_dashboard
flutter pub get
flutter run -d chrome --web-port 8081
