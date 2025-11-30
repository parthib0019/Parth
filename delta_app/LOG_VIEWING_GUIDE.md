# Delta Voice Listener - Log Viewing Guide

## 🎯 Quick Start

### Method 1: Using the Log Viewer Script
```bash
cd /workspace/Workspace/Workspace/MY\ projects/Parth/delta_app
./view_logs.sh
```

### Method 2: Direct ADB Command
```bash
$HOME/android-sdk/platform-tools/adb -s 1291231499073598 logcat | grep -E "flutter|Delta|speech"
```

### Method 3: View ALL Logs (Verbose)
```bash
$HOME/android-sdk/platform-tools/adb -s 1291231499073598 logcat
```

## 📋 What You'll See

When the app is running, you'll see logs like:
- Speech recognition status updates
- Recognized text from your speech
- "onStatus" events (listening, done, etc.)
- "onResult" events with the recognized words
- Any errors or warnings

## 🎛️ Useful ADB Logcat Commands

### Clear Previous Logs
```bash
$HOME/android-sdk/platform-tools/adb logcat -c
```

### Filter by App Package
```bash
$HOME/android-sdk/platform-tools/adb logcat | grep "com.example.delta_app"
```

### Filter by Priority (Errors and Warnings only)
```bash
$HOME/android-sdk/platform-tools/adb logcat *:E *:W
```

### Save Logs to File
```bash
$HOME/android-sdk/platform-tools/adb logcat > delta_app_logs.txt
```

## 🔍 Understanding the Output

Look for these key log messages:

1. **Speech Recognition Status**:
   - `onStatus: listening` - App is actively listening
   - `onStatus: done` - Recognition cycle completed
   - `onStatus: notListening` - Microphone is off

2. **Recognized Speech**:
   - `onResult:` - Shows what was recognized
   - Look for your print statements in the code

3. **Errors**:
   - `onError:` - Speech recognition errors
   - Permission issues
   - Microphone access problems

## 💡 Tips

- **Open the app first** on your phone before running logcat
- **Speak clearly** and check if text appears in logs
- **Press Ctrl+C** to stop viewing logs
- Use `grep` to filter for specific keywords you're interested in

## 🐛 Debugging

If you don't see any logs:
1. Make sure the app is running on your phone
2. Check device connection: `adb devices`
3. Try without grep filter to see all logs
4. Check if USB debugging is still enabled on your phone
