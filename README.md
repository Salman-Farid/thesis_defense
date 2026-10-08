# Thesis Defense — Maize Leaf Disease Detection App

Flutter application built as the working demo for my thesis defense: **on-device detection of maize leaf diseases from a photographed leaf**, with no server round-trip.

The model runs locally via TensorFlow Lite, so classification works offline and no image leaves the device.

> **Repo note:** this repository preserves the build presented at defense. Active development continues in **[plant-treatment-app](https://github.com/Salman-Farid/plant-treatment-app)**, which adds a disease library, care guides, and community feedback.

---

## What it does

1. **Capture or pick** a leaf photo (`image_picker`).
2. **Classify on-device** with a quantized TFLite model — one of four classes:
   - `Blight`
   - `Common Rust`
   - `Gray Leaf Spot`
   - `Healthy`
3. **Review the result** — prediction, symptoms, and treatment guidance.
4. **Export a PDF report** of the analysis (`pdf` + `open_file`).

## Architecture

| Layer | Implementation |
|---|---|
| UI | Flutter / Dart, `flutter_animate`, `animate_do`, `lottie`, `google_fonts` |
| ML | TensorFlow Lite (`lib/ml/model.tflite`, 4-class `lib/ml/labels.txt`) |
| Auth | Firebase Auth + Google Sign-In, credentials in `flutter_secure_storage` |
| Data | Cloud Firestore, Firebase Realtime Database |
| Reports | `pdf` → generated, then opened via `open_file` |

```
lib/
├── main.dart
├── home_page.dart           # image selection + inference
├── display_image_page.dart  # results, symptoms, treatments
├── generate_pdf.dart        # PDF export
├── ml/
│   ├── model.tflite         # quantized classifier
│   └── labels.txt           # 4 class labels
├── auth_screens/            # login, signup, splash
├── services/auth_service.dart
└── widgets/
```

## Getting started

```bash
git clone https://github.com/Salman-Farid/thesis_defense.git
cd thesis_defense
flutter pub get
flutter run
```

### Firebase setup

1. Create a Firebase project and enable **Authentication** (Email/Google) and **Firestore**.
2. Add your Android/iOS app and download:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
3. Replace the placeholders in `lib/firebase_options.dart` with your project's values.

Without Firebase config the app still builds, but sign-in and remote data will fail.

## Model

`lib/ml/model.tflite` is a quantized CNN trained on maize leaf imagery. Labels live in `lib/ml/labels.txt`. Prediction returns the class name, which is passed to the results page for symptom/treatment lookup.

## Related

- **[plant-treatment-app](https://github.com/Salman-Farid/plant-treatment-app)** — the maintained successor, with a wider disease library and care guides.
- **[plant_disease_detection](https://github.com/Salman-Farid/plant_disease_detection)** — model training and research.

## Author

**Salman Farid Rahman** — [GitHub](https://github.com/Salman-Farid) · [LinkedIn](https://www.linkedin.com/in/salman-f-rahman-8153951b1/)
