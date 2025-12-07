# 🔥 Demon Mode Protocol

> **A premium fitness & lifestyle tracking app that goes beyond the basics.**

Demon Mode Protocol is a comprehensive Flutter application designed for serious fitness enthusiasts who demand more than generic tracking apps. Built with Material Design 3 and a striking dark theme, it combines advanced sensor integration, secure data storage, and mindfulness features into one powerful package.

![App Icon](assets/icon/icon.png)

## ✨ Features

### 🏋️ Core Tracking
- **Daily Log**: Track hydration, workouts, and body transformation with integrated camera support
- **Live Pedometer**: Real-time step counting with circular progress visualization
- **Weekly Analytics**: Bar charts showing workout consistency and progress trends
- **Encrypted Database**: All data stored locally with SQLCipher encryption

### 🎯 Advanced Integrations
- **Workout Mode**
  - Built-in timer for tracking session duration
  - GPS-based distance and pace tracking for runs/jogs
  - Spotify integration for music control during workouts
- **Smartwatch Pairing**: Connect to BLE heart rate monitors for real-time HR tracking
- **Data Export/Import**: Backup and restore your progress data

### 🧘 Zen Mode
- **Box Breathing**: Visual 4-4-4-4 breathing exercise for relaxation
- **Thought Collector**: Journal your thoughts, saved securely to your daily log
- **Daily Stoic Quotes**: Wisdom from Marcus Aurelius, Seneca, and other Stoic philosophers

### 🔒 Security & Privacy
- **Biometric App Lock**: Fingerprint/Face ID or device PIN protection
- **On-Device Encryption**: All data encrypted with SQLCipher
- **No Cloud Dependencies**: Your data stays on your device
- **Onboarding Flow**: First-run permission requests and feature explanations

## 🚀 Getting Started

### Prerequisites
- Windows 10/11 (for development)
- Android device or emulator (API 21+)
- Git (for cloning)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/demon_mode.git
   cd demon_mode
   ```

2. **Setup Environment**
   
   The project includes a portable Flutter SDK and Android SDK setup:
   ```bash
   cd tools
   setup_env.bat
   ```
   
   This script will:
   - Configure Flutter SDK path
   - Set Android SDK environment variables
   - Run `flutter doctor` to verify setup

3. **Install Dependencies**
   
   In the terminal opened by `setup_env.bat`:
   ```bash
   flutter pub get
   ```

4. **Configure Spotify (Optional)**
   
   To enable Spotify integration:
   - Register your app at [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
   - Update `lib/features/workout/workout_view_model.dart`:
     ```dart
     final clientId = 'YOUR_SPOTIFY_CLIENT_ID';
     final redirectUrl = 'YOUR_REDIRECT_URL';
     ```

5. **Run the App**
   ```bash
   flutter run
   ```
   
   Or build an APK:
   ```bash
   flutter build apk --debug
   ```
   
   The APK will be located at: `build/app/outputs/flutter-apk/app-debug.apk`

## 📱 Permissions

The app requires the following Android permissions:

- **Camera**: For body transformation photos
- **Activity Recognition**: For step counting
- **Sensors**: For pedometer functionality
- **Location**: For GPS-based workout tracking
- **Bluetooth**: For smartwatch pairing
- **Biometric**: For app lock feature
- **Notifications**: For workout reminders (future feature)

All permissions are requested during the onboarding flow with clear explanations.

## 🏗️ Architecture

```
lib/
├── core/
│   ├── theme/          # Material Design 3 theme & color palette
│   └── services/       # Auth service for biometric lock
├── data/
│   ├── database/       # SQLCipher encrypted database
│   ├── models/         # Data models (DailyLog, etc.)
│   └── repositories/   # Data access layer
└── features/
    ├── auth/           # Lock screen
    ├── dashboard/      # Main dashboard with stats
    ├── daily_log/      # Daily tracking screen
    ├── devices/        # BLE device pairing
    ├── onboarding/     # First-run experience
    ├── settings/       # App settings
    ├── workout/        # Workout mode with GPS & Spotify
    └── zen_mode/       # Breathing exercises & journaling
```

## 🎨 Design Philosophy

Demon Mode Protocol uses a custom **high-contrast dark theme** with:
- **Primary Color**: Crimson Red (`#DC143C`)
- **Secondary Color**: Silver (`#C0C0C0`)
- **Background**: Pure Black (`#000000`)
- **Glassmorphism**: Frosted glass effects for cards and overlays

The design prioritizes:
- **Clarity**: High contrast for outdoor visibility
- **Focus**: Minimal distractions during workouts
- **Premium Feel**: Smooth animations and haptic feedback

## 🔧 Tech Stack

- **Framework**: Flutter 3.38.4
- **Language**: Dart 3.10.3
- **Database**: SQLite with SQLCipher encryption
- **State Management**: Provider pattern with ChangeNotifier
- **Charts**: FL Chart for data visualization
- **Sensors**: Pedometer, Geolocator
- **External APIs**: Spotify SDK
- **BLE**: Flutter Blue Plus

## 📦 Key Dependencies

```yaml
dependencies:
  sqflite_sqlcipher: ^3.1.1+1      # Encrypted database
  flutter_secure_storage: ^9.0.0   # Secure key storage
  pedometer: ^4.0.1                 # Step counting
  geolocator: ^13.0.0               # GPS tracking
  spotify_sdk: ^3.0.0               # Music integration
  flutter_blue_plus: ^1.32.7        # BLE connectivity
  local_auth: ^2.1.8                # Biometric auth
  image_picker: ^1.0.7              # Camera integration
  fl_chart: ^0.69.2                 # Data visualization
```

## 🛣️ Roadmap

- [ ] iOS support
- [ ] Workout templates and programs
- [ ] Nutrition tracking
- [ ] Social features (share progress)
- [ ] Cloud backup (optional, encrypted)
- [ ] Apple Watch integration
- [ ] Advanced analytics and insights

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Stoic quotes from Marcus Aurelius, Seneca, and Zeno
- Material Design 3 guidelines by Google
- Flutter and Dart teams for an amazing framework

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Built with 🔥 for those who refuse to settle for average.**
