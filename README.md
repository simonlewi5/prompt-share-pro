# Flutter App Setup Guide

This guide will walk you through the necessary steps to set up the environment to run our Flutter app.

## Prerequisites

Ensure that the following software versions are installed to avoid compatibility issues:

- **Flutter SDK**: Version 3.24.4
- **Dart SDK**: Version 3.5.4
- **Android Studio** (with Android SDK and Virtual Device installed)

## Installation Steps

### 1. Install Flutter and Dart SDKs

1. Download and install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Ensure Dart is included with your Flutter installation, as Flutter includes Dart SDK. However, make sure to set up both Flutter and Dart within Android Studio, as described below.

### 2. Configure Android Studio

1. Open **Android Studio**.
2. Go to **File > Settings** (or **Preferences** on macOS).
3. Navigate to **Plugins** and ensure the **Flutter** and **Dart** plugins are installed.
   - If not, search for "Flutter" and "Dart" in the marketplace and install them.
4. Restart Android Studio if prompted.

### 3. Set Up a Virtual Device

1. Open **Android Studio**.
2. Go to **Tools > Device Manager**.
3. Click **Create Device** and choose **Pixel 8 Pro**.
4. Select and download the **API 30** system image.
5. No other configuration needed, select **Finish**
5. Complete the setup and ensure the virtual device runs correctly.

### 4. Open the Project Directory

When working on the front end, **open only the `flutter_app` directory** in Android Studio. This ensures that dependencies load correctly and reduces clutter.

### 5. Run the App

1. Select the virtual device you created with API 30 as your target device.
2. Press **Run** (the play button) or use the command `flutter run` in the terminal to start the app.

## Additional Notes

- Make sure to keep your Flutter and Dart SDKs updated to maintain compatibility.
- If you encounter issues, try running `flutter doctor` in your terminal to check for any missing dependencies or configurations.
- You may need to download all packages and dependencies so to be safe run `flutter pub get` before running app.

Now you're ready to start working with the app!
