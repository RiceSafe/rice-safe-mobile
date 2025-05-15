# RiceSafe Mobile Application

RiceSafe is a Flutter application designed to help users diagnose rice diseases by uploading an image of the rice disease and providing a description of its symptoms. The app communicates with a AI server(for now) for analysis and then presents the diagnosis and treatment recommendations.

## Features

- **Image Upload:** Users can select an image of a rice plant from their gallery.
- **Symptom Description:** Users can provide a textual description of the observed symptoms.
- **AI-Powered Diagnosis:** Connected with the AI server to predict the rice disease.
- **Diagnosis Results:** Displays the predicted disease result.
- **Treatment Information:** Provides recommendations for "วิธีการรักษา" (Remedy) and "การควบคุมดูแล" (Treatment).
- **User-Friendly Interface:** Clean and intuitive UI for ease of use.

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **UI Components:** Material Design

## Prerequisites

- **Flutter SDK** (latest stable version recommended)
- An IDE like VS Code or Android Studio/IntelliJ IDEA for Flutter and Go development.

## Project Structure

```
ricesafe_app/
├── android/                    # Android specific files
├── assets/                     # Contains app assets like icons
│   └── rice_icon.png
├── ios/                        # iOS specific files
├── ...
├── lib
│   ├── core
│   │   └── config
│   │       └── app_config.dart # App-wide configurations
│   ├── input_screen.dart       # App entry point, theme
│   ├── main.dart               # Screen for user input (image & description)
│   └── result_screen.dart      # Screen to display diagnosis results
├── .env.example                # Example environment variables
├── pubspec.yaml                # Flutter project dependencies and metadata
└── README.md                   # This file
```

## Installation Guide

- **Clone the repository:**

  ```bash
  git clone https://github.com/RiceSafe/rice-safe-mobile.git
  ```

  Change directory to project directory

  ```bash
  cd rice-safe-mobile
  ```

- **Create Environment File (`.env`):**
  Create a file named `.env` in the `rice-safe-mobile/` directory.
  This file is used by `flutter_dotenv` to load environment variables into the Flutter app.

  Or you can copy `.env.example`

  ```bash
  cp .env.example .env
  ```

  ```dotenv
  # Flutter Environment Variables
  # Copy this file to .env and set the correct values

  # Base URL for Go backend API (Right now it's connected with AI Server)
  API_BASE_URL=http://localhost:8000
  ```

- **Install Flutter Dependencies:**

  ```bash
  flutter pub get
  ```

  - **Run the Flutter App:**
  - Select a device/emulator.
  - Run from your IDE or use the command:
    ```bash
    flutter run
    ```
  - If running on a physical device and the server is on `localhost`, ensure your device can reach your machine's IP address and update `API_BASE_URL` in Flutter's `.env` accordingly.
