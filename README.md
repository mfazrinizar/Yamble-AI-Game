# Yamble: Yap to Gamble | AI-based Game

Welcome to **Yamble: Yap to Gamble**, a real-time AI-based multiplayer game built with Flutter and Firebase Firestore. This project aims to create a dynamic and engaging gaming experience where players compete by solving AI-generated scenarios.

<div style="display:flex;">
    <img src="https://github.com/user-attachments/assets/d85cb6fc-41b8-4586-ad13-7b9f29a8ff0a" alt="Logo" width="256"/>
</div>

## Introduction

Yamble: Yap to Gamble is a realtime multiplayer game developed as a mobile application using Flutter and Firebase Firestore. The game supports multiple users simultaneously, creating an engaging and competitive gaming environment. AI-generated scenarios present unique challenges to players, who must submit their best solutions within a time limit. These solutions are then evaluated by the AI, determining their success and contributing to the players' ranks and scores. The game's intuitive design ensures a smooth and user-friendly experience, with real-time updates and feedback enhancing gameplay.

Key features of Yamble include:
 - Realtime multiplayer gameplay with Firebase Firestore for data sync
 - AI-generated scenarios for unique challenges
 - Solution evaluation by AI for fair scoring
 - Ranks system and leaderboard to track player performance
 - Intuitive and user-friendly interface for an engaging experience

## Pages Screenshots
![Pages of Yamble](https://github.com/user-attachments/assets/1b9fb2e2-0baf-4557-aa3c-13de83f717d7)

## Tech Stack
- Flutter
- Firebase Firestore
- Generative AI (Gemini 1.5 Flash)

## Prerequisites
- [Flutter](https://docs.flutter.dev/get-started/install) installed on your machine.
- [Firebase account](https://firebase.google.com/) for backend integration.
- [Google AI Studio Account](https://aistudio.google.com/app/apikey) for generative AI.

## How to Run
1. Install Java JDK (add to PATH), Android Studio, VS Code (or any preferred IDE), Flutter SDK, etc. to install all needed tools (SDK, NDK, extra tools) for Android development toolchain, please refer to this [link](https://docs.flutter.dev/get-started/install).
2. Clone this repository.
3. Run `flutter pub get` to get rid of problems of missing dependencies.
4. Generate keystore to sign in release mode with command `keytool -genkey -alias server -validity 9999 -keyalg RSA -keystore keystore` using keytool from Java.
5. Rename the generated keystore with `<anyName>.keystore`.
6. Place the `<anyName>.keystore` to app-level Android folder (android/app/).
7. Create new file with name `key.properties` inside project-level Android folder (android/) with properties/contents as follow:
`storePassword=<yourKeyPassword>
keyPassword=<yourKeyPassword>
keyAlias=<yourKeyAlias>
storeFile=<anyName>.keystore`
8. Using your browser, navigate to [Firebase Console](https://console.firebase.google.com/) to setup the Firebase integration.
9. Click add project then proceed with the steps shown in Firebase Console web (setup Authentication, Firestore DB and Storage).
10. Download `google-services.json` and place it to app-level Android folder (android/app/).
11. Edit `.env.example` name to `.env`, then edit value of each environment variables according to your API (check [Firebase Console](https://console.firebase.google.com/) for all Firebase-related API, [Gemini](https://aistudio.google.com/app/apikey) for Generative AI API Key).
12. If you don't want to generate your own AES 128/192/256 key, run `dart run build_runner build --define secure_dotenv_generator:secure_dotenv=OUTPUT_FILE=encryption_key.json`. If you decided to generate your own, run `dart run build_runner build --define secure_dotenv_generator:secure_dotenv=ENCRYPTION_KEY=yourEncryptionKey  --define secure_dotenv_generator:secure_dotenv=IV=yourIvKey --define secure_dotenv_generator:secure_dotenv=OUTPUT_FILE=encryption_key.json`.
13. Run `flutter build apk --release --split-per-abi --obfuscate --split-debug-info=/debug_info/` for splitted APK (each architecture) or `flutter build apk --release --obfuscate --split-debug-info=/debug_info/` for FAT APK (contains all ABIs)
14. Your build should be at `build/app/outputs/flutter-apk` <br>
Facing problems? Kindly open an issue.

## How to Contribute
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.
- Fork the Project
- Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
- Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
- Push to the Branch (`git push origin feature/AmazingFeature`)
- Open a Pull Request
