
# 🌱 PlantTreatmonty: Plant Disease Detection App

PlantTreatmonty is a Flutter-based mobile application designed to help users identify plant diseases, gain plant care insights, and access a library of common plant diseases. Powered by a quantized ML model for efficient on-device inference, this app provides fast and accurate plant disease detection without relying on server-based predictions. Additional features include user authentication via Firebase, a plant care tips section, and an extensive disease library for users to explore.

---

## 📱 Features

- **Plant Disease Detection**: Quickly identify plant diseases by uploading or capturing plant images. The app uses a quantized ML model optimized for mobile to provide fast and accurate results.
- **Firebase Authentication**: Secure user login and signup powered by Firebase.
- **Plant Care Tips**: Discover tips for maintaining healthy plants and preventing disease.
- **Disease Library**: Access a comprehensive library of common plant diseases, including images, symptoms, and treatments.
- **Responsive Design**: A user-friendly interface that adapts to various screen sizes for an optimal experience.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed on your machine.
- Firebase project with Authentication enabled.

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/plant_treatmonty.git
   cd plant_treatmonty
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Set up Firebase:

    - Go to the [Firebase Console](https://console.firebase.google.com/), create a new project, and enable Firebase Authentication.
    - Download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files and place them in the appropriate directories:
        - `android/app/` for `google-services.json`
        - `ios/Runner/` for `GoogleService-Info.plist`

4. Configure Firebase and ML model assets in `pubspec.yaml`:

   ```yaml
   assets:
     - assets/models/plant_disease_model.tflite
   ```

5. Run the app:

   ```bash
   flutter run
   ```

---

## 🌿 Screenshots

| Feature              | Screenshot |
|----------------------|------------|
| Disease Detection    | ![Detection](path_to_screenshot) |
| Login/Signup         | ![Authentication](path_to_screenshot) |
| Disease Library      | ![Library](path_to_screenshot) |
| Plant Care Tips      | ![Tips](path_to_screenshot) |

---

## 🔥 Technical Details

- **Flutter Framework**: A cross-platform UI toolkit to build the app for both Android and iOS.
- **Firebase Authentication**: Manages user authentication securely.
- **TensorFlow Lite**: ML model quantized for efficient, on-device disease detection.
- **Dart**: Main programming language used in Flutter development.

### ML Model

The app uses a quantized ML model trained for detecting plant diseases. The model is optimized to perform predictions directly on the device for low latency and offline functionality.

---

## 🌟 Future Improvements

- **Offline Disease Library**: Allow users to access disease information offline.
- **Additional Plant Care Tips**: Expand the database of plant care tips.
- **Community Contributions**: Enable users to submit new diseases and share their experiences.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [TensorFlow Lite](https://www.tensorflow.org/lite) for providing tools to deploy efficient machine learning models on mobile.
- [Flutter Documentation](https://flutter.dev/docs) for their comprehensive resources.
- [Firebase](https://firebase.google.com/) for the backend authentication support.

--- 

