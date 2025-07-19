# Impressaa

A production-grade Flutter boilerplate for scalable, reusable Android and iOS apps.

## Overview

This project is a modular, production-ready Flutter boilerplate designed for all future projects. It follows Clean Architecture principles (DRY, SOLID, KISS) and supports features like localization, theme switching (dark/light mode), and dependency injection. The structure is plug-and-play, allowing developers to reuse features and utilities across projects with minimal changes.

## Getting Started

### Prerequisites

Ensure your environment is set up:

```bash
flutter doctor
```

Verify Android and iOS toolchains are installed (Android SDK, Xcode, CocoaPods).

### Emulator Setup

#### List Available Emulators

```bash
flutter emulators
```

Shows available Android and iOS emulators (e.g., `Medium_Phone_API_35`, `apple_ios_simulator`).

#### Start Android Emulator

```bash
flutter emulators --launch Medium_Phone_API_35
```

Launches a modern Android emulator (API 35 recommended).

#### Start iOS Simulator

```bash
flutter emulators --launch apple_ios_simulator
```

Launches the iOS simulator (e.g., iPhone 16, iOS 18).

#### Stop Android Emulator

```bash
adb emu kill
```

Stops all running Android emulators.

#### Stop iOS Simulator

```bash
xcrun simctl shutdown all
```

Shuts down all running iOS simulators.

#### Verify Running Devices

```bash
flutter devices
```

Lists active devices (emulators/simulators) for running the app.

### Running the App

1. Start the Android emulator and iOS simulator (see above).
2. Run the app on both platforms:
   ```bash
   flutter run -d all
   ```
   Or, run individually:
   ```bash
   flutter run -d Medium_Phone_API_35
   flutter run -d "SM M346B"
   flutter run -d <ios_simulator_id>
   ```
   Replace `<ios_simulator_id>` with the simulator name or UUID from `flutter devices`.

### Project Structure

```
lib/
├── main.dart                    # App entry point
├── app/                        # App configuration and routing
├── core/                       # Shared utilities (DI, localization, networking)
├── features/                   # Feature modules (e.g., login, signup)
├── shared/                     # Reusable widgets and themes
├── test/                       # App-wide tests
└── generated/                  # Auto-generated code
```

- Features are modular and reusable across projects.
- Core utilities (e.g., `network_service.dart`, `validators.dart`) are plug-and-play.
- Testing and localization ensure production readiness.

### Resources

- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)

For issues, run `flutter doctor` or consult the Flutter documentation.
