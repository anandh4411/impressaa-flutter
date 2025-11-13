# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Impressaa is a production-grade Flutter ID card management app built with Clean Architecture principles. It's a modular boilerplate designed for scalable Android and iOS apps with support for localization, theme switching (dark/light mode), and dependency injection.

## Development Commands

### Running the App

```bash
# Check Flutter environment
flutter doctor

# List available emulators
flutter emulators

# Launch Android emulator
flutter emulators --launch Medium_Phone_API_35

# Launch iOS simulator
flutter emulators --launch apple_ios_simulator

# Check running devices
flutter devices

# Run on all devices
flutter run -d all

# Run on specific device
flutter run -d Medium_Phone_API_35
flutter run -d "SM M346B"

# Get debug APK
flutter build apk --debug
```

### Emulator Management

```bash
# Stop Android emulators
adb emu kill

# Stop iOS simulators
xcrun simctl shutdown all
```

### Testing and Analysis

```bash
# Run all tests
flutter test

# Run tests in a specific file
flutter test test/features/auth/auth_bloc_test.dart

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## Architecture

### Core Structure

The app follows a feature-based modular architecture with clear separation of concerns:

- **lib/main.dart** - Entry point that initializes DI and launches the app
- **lib/app/** - App-level configuration, routing, and theme setup
- **lib/core/** - Shared infrastructure (DI, localization, theme)
- **lib/features/** - Feature modules organized by domain
- **lib/shared/** - Reusable widgets and components
- **test/** - Mirror structure of lib/ for tests

### Key Architectural Patterns

**State Management**: BLoC pattern via `flutter_bloc`
- Each feature has its own BLoC with events, states, and business logic
- Example: `DynamicFormBloc` handles form loading, validation, and preview

**Dependency Injection**: GetIt service locator
- Setup in `lib/core/di/injection.dart`
- Register all services, repositories, and BLoCs in `setupDependencies()`
- Access via `getIt<T>()` or `getIt.get<T>()`

**Navigation**: GoRouter declarative routing
- All routes defined in `lib/app/routes/app_router.dart`
- Use `context.go()` for navigation or `context.push()` for stack navigation
- Complex data passing via `extra` parameter (see form preview route for example)

**UI Framework**: shadcn_ui with Cupertino
- ShadApp wraps CupertinoApp for cross-platform feel
- Themes support both light/dark modes with 12 color schemes
- Change color scheme in `lib/app/app.dart` (colorSchemeName constant)

### Features Architecture

Each feature follows this structure:
```
features/[feature_name]/
├── [feature_name]_page.dart        # UI entry point
├── components/                      # Feature-specific widgets
├── data/                            # Models and data layer
└── state/                           # BLoC (events, states, bloc)
```

**Dynamic Form System**: The core feature demonstrates the architecture:
- `FormConfigModel` defines form structure fetched from API/backend
- `DynamicFormBloc` handles form lifecycle and validation
- `dynamic_form_field.dart` renders appropriate widgets based on field type
- Supports: text, email, phone, number, textarea, select, date, file fields

### Theme System

Themes are centralized in `lib/core/theme/app_theme.dart`:
- Support for 12 shadcn color schemes: blue, gray, green, neutral, orange, red, rose, slate, stone, violet, yellow, zinc
- Automatic light/dark mode based on system preferences
- Google Fonts integration (currently Poppins)

### Testing Structure

Tests mirror the lib/ directory structure:
- Unit tests for BLoCs use `bloc_test` package
- Mock dependencies with `mocktail`
- Test structure: core/, features/, helpers/, shared/

## Important Implementation Notes

### Form Field Validation

All form validation happens in `DynamicFormBloc._validateForm()`:
- Required field checks
- Type-specific validation (email, phone, number)
- Length constraints (minLength, maxLength)
- Custom regex patterns via FormValidation model

### Navigation with Complex Data

When passing complex objects between routes (especially with GoRouter):
- Use `extra` parameter in `context.push/go`
- Explicitly handle type casting with fallbacks (see `/form/preview` route)
- Always provide fallback navigation if data is invalid

### Photo Capture Flow

The app includes a camera integration flow:
1. Form submission → 2. Photo capture → 3. Preview with photo
- Uses `camera` package for image capture
- Photo passed as File object through navigation
- Integration point: `photo_capture_page.dart`

### Dependency Registration

When adding new features that need DI:
1. Create the service/repository/BLoC
2. Register in `lib/core/di/injection.dart` → `setupDependencies()`
3. Use `registerSingleton()` for app-wide services
4. Use `registerFactory()` for per-request instances (like BLoCs)

## Dependencies

Key packages:
- **shadcn_ui**: UI component library
- **flutter_bloc**: State management
- **get_it**: Dependency injection
- **go_router**: Declarative routing
- **dio**: HTTP client
- **shared_preferences**: Local storage
- **camera**: Camera access
- **google_fonts**: Typography
- **url_launcher**: External URLs/phone calls
- **image**: Image processing

Dev dependencies:
- **bloc_test**: BLoC testing utilities
- **mocktail**: Mocking framework
- **flutter_lints**: Code analysis rules
