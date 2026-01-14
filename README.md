# RiceSafe Mobile Application

RiceSafe is a Flutter application designed to help users diagnose rice diseases by uploading an image of the rice disease and providing a description of its symptoms. The app communicates with an AI server for analysis and then presents the diagnosis and treatment recommendations.

## Features

- **Image Upload:** Users can select an image of a rice plant from their gallery.
- **Symptom Description:** Users can provide a textual description of the observed symptoms.
- **Speech-to-Text:** Users can use Thai voice input ("th_TH") to describe symptoms by tapping the microphone icon.
- **AI-Powered Diagnosis:** Connected with the AI server to predict the rice disease and provide confidence scores.
- **Diagnosis Results:** Displays the predicted disease result, remedy, and preventative treatment advice.
- **Outbreak Map:** Interactive map showing disease outbreak locations and indicating the user's distance from them.
- **Community Feed:** A social platform for farmers to share posts, view updates, and interact with the community.
- **User-Friendly Interface:** Clean and intuitive UI with bottom navigation for easy access to all features.

## Tech Stack

- **Framework:** Flutter (Dart)
- **Architecture:** Clean Architecture (Feature-first)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Networking:** Dio
- **Maps:** flutter_map with latlong2
- **Speech Recognition:** speech_to_text

## Architecture

RiceSafe follows a **Feature-first Clean Architecture** pattern to ensure scalability, maintainability, and testability.

### Layers
Each feature (e.g., `diagnosis`, `auth`) is self-contained with its own layers:
1.  **Data Layer (`data`):**
    *   **Data Sources:** Handle raw API calls (e.g., `DioClient`).
    *   **Repositories:** Implement the interface to fetch data and handle errors.
2.  **Domain/Model Layer (`models`):**
    *   **Entities:** Pure Dart classes representing the data (e.g., `DiagnosisResult`).
3.  **Presentation Layer (`presentation`):**
    *   **Screens:** The UI widgets (e.g., `DiagnosisInputScreen`).
    *   **Providers:** State management logic (Riverpod) connecting UI to Data.

### Core
Shared resources like Networking, Routing, and Configuration are located in `lib/core`.

## Project Structure

```
rice-safe-mobile/
├── lib/
│   ├── core/
│   │   ├── config/             # App-wide configurations (e.g. EnvConfig)
│   │   ├── error/              # Failure and Exception classes
│   │   ├── network/            # Dio client and Interceptors
│   │   └── router/             # GoRouter configuration (`app_router.dart`)
│   │
│   ├── features/               # Feature-based modules
│   │   ├── diagnosis/          # [Example Feature Structure]
│   │   │   ├── data/
│   │   │   │   ├── data_sources/   # Remote/Local data sources
│   │   │   │   └── diagnosis_repository.dart
│   │   │   ├── models/             # Data models (e.g. DiagnosisResult)
│   │   │   └── presentation/
│   │   │       ├── providers/      # Riverpod Notifiers
│   │   │       └── screens/        # UI Widgets
│   │   │
│   │   ├── auth/               # Login & Register
│   │   ├── community/          # Social Feed
│   │   ├── home/               # Dashboard
│   │   ├── library/            # Disease Encyclopedia
│   │   ├── outbreak/           # Map & Alert System
│   │   └── settings/           # Profile & Settings
│   │
│   └── main.dart               # App entry point
├── .env.example                # Example environment variables
├── pubspec.yaml                # Project dependencies
└── README.md                   # This file
```

## Prerequisites

- **Flutter SDK** (latest stable version recommended)
- An IDE like VS Code or Android Studio/IntelliJ IDEA for Flutter development.

## Installation Guide

- **Clone the repository:**

  ```bash
  git clone https://github.com/RiceSafe/rice-safe-mobile.git
  ```

  Change directory to project directory

  ```bash
  cd rice-safe-mobile
  ```

- **Update Dependencies:**

  ```bash
  flutter pub get
  ```

- **Create Environment File (`.env`):**
  Create a file named `.env` in the root directory.

  ```bash
  cp .env.example .env
  ```

  ```dotenv
  # Base URL for AI Server
  # If running on a physical device, use your machine's IP address (e.g., http://192.168.1.5:8000)
  BASE_URL=http://<YOUR_IP>:8000
  ```

- **Run the Flutter App:**

  ```bash
  flutter run
  ```

## Permissions

To use all features, the app requires the following permissions:
- **Camera/Photo Library:** For uploading disease images.
- **Microphone:** For speech-to-text symptom description.
- **Location:** For calculating distance to outbreak areas.
