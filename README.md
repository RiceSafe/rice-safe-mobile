# RiceSafe Mobile Application

RiceSafe is a Flutter app for farmers: upload or photograph affected rice, describe symptoms, and read back a disease-oriented result and guidance from the RiceSafe backend. Signed-in use covers diagnosis, community, maps, and personal settings.

## Features

- **Diagnosis:** Choose a photo from the gallery or take one in the app; add symptom text; optional Thai voice input from the microphone. Results show disease-oriented information (including remedy and prevention when returned). Optional farm location can accompany a diagnosis when the user has set it.
- **Diagnosis history:** List of past checks.
- **Disease library:** Browse disease information and open detail views.
- **Outbreak map:** Map of outbreak-related points with the user’s location for context and distance.
- **Home:** Overview and shortcuts (including notifications and profile access from the app bar).
- **Notifications:** In-app notification list and unread count.
- **Community:** Feed, create posts, and open a post to read or add comments.
- **Account:** Email/password sign-in and registration; sign-in with Google or LINE; forgot and reset password; registration onboarding for profile photo and farm location.
- **Settings:** Edit profile, set farm location on a map, contact support, app/about information.
- **Navigation:** After sign-in, bottom navigation: หน้าหลัก, คลังความรู้, วินิจฉัย (center action), ชุมชน, แผนที่ระบาด.

## Tech Stack

- **Framework:** Flutter (Dart SDK `^3.7.2`, package name `ricesafe_app`)
- **Layout:** Feature-oriented modules under `lib/features`; shared code under `lib/core`
- **State:** `flutter_riverpod`
- **Routing:** `go_router`
- **HTTP:** `dio` (Bearer from `authTokenProvider`); `http` / `http_parser` also listed in `pubspec.yaml`
- **Env:** `flutter_dotenv` (`.env` asset)
- **Local storage:** `hive_flutter` (auth token box); `shared_preferences` (farm location and related)
- **Maps:** `flutter_map`, `latlong2`, `geolocator`
- **Speech:** `speech_to_text`
- **Media:** `image_picker`, `camera`
- **OAuth:** `google_sign_in`, `flutter_line_sdk`
- **Other:** `dartz`, `equatable`, `intl`, `dotted_border`, `package_info_plus`

## Architecture

RiceSafe follows a **Feature-first Clean Architecture** pattern to ensure scalability, maintainability, and testability.

### Layers

Each feature (e.g., `diagnosis`, `auth`) is self-contained with its own layers:

1. **Data Layer (`data`):**
  - **Data Sources:** Handle raw API calls via shared `dioProvider` (Dio + interceptors).
  - **Repositories:** Implement the interface to fetch data and handle errors.
2. **Domain/Model Layer (`models`):**
  - **Entities:** Pure Dart classes representing the data (e.g., `DiagnosisResult`).
3. **Presentation Layer (`presentation`):**
  - **Screens:** The UI widgets (e.g., `DiagnosisInputScreen`).
  - **Providers:** State management logic (Riverpod) connecting UI to Data.

### Core

Shared resources like Networking, Routing, and Configuration are located in `lib/core`.

## Project Structure

```
rice-safe-mobile/
├── lib/
│   ├── core/
│   │   ├── config/             # EnvConfig (BASE_URL, LINE_CHANNEL_ID)
│   │   ├── error/              # Failures, exceptions, user-facing messages
│   │   ├── map/                # Shared map tile layer + attribution
│   │   ├── network/            # dio_provider, dio_error_detail
│   │   ├── router/             # GoRouter, auth refresh listenable
│   │   └── widgets/            # e.g. app bar profile, notification badge
│   ├── features/
│   │   ├── auth/               # Login, register, onboarding, OAuth, token storage
│   │   ├── community/          # Feed, create post, post detail / comments
│   │   ├── diagnosis/          # Input, camera, result, history, repository, parser
│   │   ├── home/               # Home screen, dashboard providers
│   │   ├── library/            # Disease library list and detail
│   │   ├── main/               # MainWrapper (bottom navigation shell)
│   │   ├── notifications/      # API-backed notifications
│   │   ├── outbreak/           # Outbreak map screen and data
│   │   └── settings/         # Settings, profile, farm location, support, about
│   └── main.dart               # Hive init, dotenv, optional LineSDK.setup, ProviderScope
├── test/
│   ├── integration/            # e.g. smoke_test (RiceSafeApp + TestHive)
│   └── helpers/
├── assets/                     # Bundled assets (see pubspec `assets:`)
├── .env.example
├── pubspec.yaml
└── README.md
```

## Prerequisites

- Flutter SDK (compatible with Dart `^3.7.2`)
- IDE: VS Code or Android Studio / IntelliJ with Flutter plugins

## Installation

Clone the repository:

```bash
git clone https://github.com/RiceSafe/rice-safe-mobile.git
```

Change directory to project directory:

```bash
cd rice-safe-mobile
```

Update Dependencies:

```bash
flutter pub get
```

Create `.env`:

```bash
cp .env.example .env
```

Set at least:

```dotenv
# Backend API base URL (must include /api suffix used by route constants in the app)
# iOS Simulator / same host: http://localhost:8080/api
# Android emulator: http://10.0.2.2:8080/api
# Physical device: http://<LAN_IP>:8080/api
BASE_URL=http://localhost:8080/api

# LINE Login — required in .env for LineSDK.setup in main.dart when using LINE sign-in
LINE_CHANNEL_ID=your_line_channel_id_here

# Optional: true or 1 to use diagnosis fixtures and mock history (no POST/GET diagnosis over the network)
# USE_MOCK_DIAGNOSIS=false
```

Run:

```bash
flutter run
```

## Permissions

Declared for platform builds as needed for the above plugins, including:

- **Camera / photo library:** disease images
- **Microphone:** speech-to-text
- **Location:** outbreak map and diagnosis location when granted

