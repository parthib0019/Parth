#!/bin/bash
# Delta App Log Viewer
# This script shows real-time logs from the Delta Voice Listener app

echo "🎤 Delta Voice Listener - Live Logs"
echo "===================================="
echo ""
echo "Make sure the app is running on your phone!"
echo "Press Ctrl+C to stop viewing logs"
echo ""

# Use the local Android SDK
export ANDROID_SDK_ROOT=$HOME/android-sdk
export PATH=$HOME/android-sdk/platform-tools:$PATH

# Clear the log buffer first (optional)
# adb logcat -c

# Show logs filtered for Flutter app
# The package name is com.example.delta_app
adb -s 1291231499073598 logcat | grep -E "flutter|Delta|speech"
