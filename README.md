# mpepo_kitchen_pos_app

A Flutter POS (Point-of-Sale) application for managing kitchen orders, products, and invoices.

---

## Getting Started

This guide will help you set up and run the project locally.

### Prerequisites

Before running the app, make sure you have:

1. **Flutter SDK** installed:

    * [Flutter installation guide](https://docs.flutter.dev/get-started/install)
    * Verify installation:

      ```bash
      flutter doctor
      ```
2. **Android Studio / VS Code** or any IDE of your choice with Flutter support.
3. **Android Emulator** or physical device connected.
4. **Dart SDK** (comes with Flutter).

---

## Project Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/ObrienChimbulu/Mpepo_Kitchen_Pos_App.git
   cd mpepo_kitchen_pos_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run on Android/iOS**

    * To run on Android:

      ```bash
      flutter run
      ```
    * To run on a specific device/emulator:

      ```bash
      flutter devices
      flutter run -d <device-id>
      ```

4. **Build APK for Android**

   ```bash
   flutter build apk --debug
   ```

    * The debug APK will be available at:

      ```
      build/app/outputs/flutter-apk/app-debug.apk
      ```

5. **Build App Bundle for Play Store**

   ```bash
   flutter build appbundle
   ```

---

## Project Structure

```
lib/
 ├─ main.dart                # App entry point
 ├─ config/                  # Configuration files (API, theme)
 ├─ models/                  # Data models (Product, Order, Invoice)
 ├─ providers/               # State management using Provider
 ├─ screens/                 # UI screens (Login, Orders, Products, Invoices)
 ├─ widgets/                 # Reusable UI components
 └─ services/                # API & local storage services
```

---

## Environment Configuration

* The API base URL is defined in `lib/config/api_config.dart`.
* If using an Android emulator, use `http://10.0.2.2:8000` to connect to your local backend.
* For physical devices, use your computer's local network IP.

---

## Troubleshooting

* **Flutter doctor errors:**
  Run:

  ```bash
  flutter doctor -v
  ```

  Follow the instructions to resolve missing dependencies.

* **Emulator not detected:**
  Make sure your device is running and recognized:

  ```bash
  flutter devices
  ```

* **Hot reload/hot restart issues:**
  Sometimes a full rebuild is needed:

  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

---

## Resources

* [Flutter documentation](https://docs.flutter.dev/)
* [State management with Provider](https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple)
* [Flutter UI widgets](https://docs.flutter.dev/development/ui/widgets)

---

## Author

Created by [Your Name]
Version: 1.0.0
