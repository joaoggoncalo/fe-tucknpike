# TuckNPike Hybrid App

This is the hybrid mobile application for TuckNPike, a trampoline gymnastics training platform. The app is built with Flutter and runs on both Android and iOS.

## Prerequisites

- **Flutter SDK:** Install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)
- **Dart SDK:** (Usually comes with Flutter)
- **Android Studio or Xcode:** For building the app on Android and/or iOS.
- **Git:** To clone the repository.
- **A device or emulator:** For testing the app.

## Setup

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/yourusername/fe_tucknpike.git
   cd fe_tucknpike
    ```

2. Install Dependencies:


```bash
flutter pub get
```

3. Configure Environment Variables:

Copy the example environment file:

```bash
cp .env.example .env
```

Edit the .env file to set the following variables:

BASE_URL: The base URL of your backend API (e.g., https://api.tucknpike.nl or https://api-dev.tucknpike.nl)

4. Run the Application:

For Android:

```bash
flutter run --release -d <android-device-id>
```



## Build Environments
The app supports different build environments using the flutter_dotenv package. Adjust the variables in your .env file accordingly.

# Deployment
To build an APK for Android:

```bash
flutter build apk --release
```


Notes
Native Functionality:
The app uses GPS for updating training locations. Make sure your device/emulator has location services enabled.

Error Handling:
The app provides feedback through SnackBars if any user input error or network error occurs.

Routing:
Navigation is handled by go_router. Use deep links or navigation buttons to move between pages.

