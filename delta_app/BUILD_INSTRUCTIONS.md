# Delta Voice Listener - Build Instructions

## Current Status

The Delta Voice Listener app has been fully implemented with the following features:
- ✅ Continuous speech recognition
- ✅ "Delta" keyword detection
- ✅ Real-time log display with "ignoring:" and "recognising:" prefixes
- ✅ Modern dark-themed UI with cyan accents
- ✅ Auto-scrolling log view
- ✅ Microphone permission handling

## Build Issue

The build is currently blocked by an **NDK license issue** in the development environment. The system Android SDK at `/opt/android-sdk` is read-only, preventing license acceptance for NDK components.

## Solution: Build on Your Device

Since you have a physical Android device, here's how to build and install the app:

### Option 1: Using Flutter (Recommended)

1. **Connect your Android device** via USB and enable USB debugging
2. **Navigate to the project directory**:
   ```bash
   cd /workspace/Workspace/Workspace/MY\ projects/Parth/delta_app
   ```

3. **Check device connection**:
   ```bash
   flutter devices
   ```

4. **Run the app directly** (this will build and install):
   ```bash
   flutter run
   ```

### Option 2: Build APK on Your Local Machine

If the above doesn't work due to SDK issues, you can:

1. **Copy the project** to your local machine (where you have Android Studio or a properly configured Flutter SDK)

2. **Build the APK**:
   ```bash
   flutter build apk --release
   ```

3. **Install the APK** on your phone:
   - The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`
   - Transfer it to your phone and install it

### Option 3: Fix SDK Permissions (Advanced)

If you have sudo access, you can fix the SDK permissions:

```bash
sudo chown -R $USER:$USER /opt/android-sdk
flutter doctor --android-licenses
flutter build apk --debug
```

## App Features

Once installed, the app will:

1. **Request microphone permission** on first launch
2. **Start listening automatically** for ambient speech
3. **Display all recognized speech** in the log view:
   - Lines containing "delta" → `recognising: <sentence>`
   - Lines without "delta" → `ignoring: <sentence>`
4. **Auto-scroll** to show the latest entries
5. **Run in the background** (tap the mic button to pause/resume)

## Next Steps (After Installation)

Once you get the app running, we can add:
- ✨ Local LLM integration (Gemma 2B or TinyLlama)
- 🔊 Text-to-Speech responses
- 🎯 Improved wake word detection
- 💾 Persistent conversation history
- ⚙️ Settings and customization

## Project Structure

```
delta_app/
├── lib/
│   └── main.dart          # Main app code (complete)
├── android/
│   ├── app/
│   │   └── src/main/AndroidManifest.xml  # Permissions configured
│   └── build.gradle.kts   # Build configuration
└── pubspec.yaml           # Dependencies (speech_to_text, etc.)
```

## Troubleshooting

**"Microphone permission denied"**
- Go to Settings → Apps → Delta AI → Permissions → Enable Microphone

**"Speech recognition not available"**
- Ensure Google app is installed and updated
- Check internet connection (for initial model download)

**App crashes on startup**
- Check Android version (minimum SDK 21 / Android 5.0)
- Clear app data and try again
