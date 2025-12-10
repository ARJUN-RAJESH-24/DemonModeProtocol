# Demon Mode Protocol

> *"Hard things, done daily."*

**Demon Mode Protocol** is a high-performance productivity and fitness ecosystem designed to force discipline and track progress. Built with **Flutter** and **Dart**, it combines fitness tracking, habit formation, and rigorous productivity tools into a unified "Demon Mode" experience.

![Status](https://img.shields.io/badge/Status-Deployment%20Ready-green)
![Build](https://img.shields.io/badge/Build-Optimized-blue)
![Security](https://img.shields.io/badge/Security-Encrypted%20%26%20Obfuscated-secure)

---

## 🚀 Key Features

### 1. **Daily Transformation & Log History**

* **Accountability Tracking:** Log water intake, caffeine, mood (with % score), and sleep hours.
* **Log History:** *[NEW]* Full calendar view to revisit past days.
* **Detailed Archives:** View historical snapshots including photos, detailed workout logs, and nutrition breakdown.
* **Journal & Conquests:** Daily reflection prompts and a "Conquests" log to record small victories.
* **Custom Habits:** Define non-negotiables (e.g., "Creatine", "Reading", "Deep Work") and track them daily.
* **Physique Check:** Capture daily progress photos to visualize your physical transformation.

### 2. **Gym Mode (War Room)**

* **Session Tracking:** Real-time workout timer with "Active" and "Rest" states.
* **Dual Modes:** Toggle between **Gym/Strength** (Sets, Reps, Weight) and **Cardio/Run** (Distance, Energy, Pace).
* **Session Log:** Detailed history of every set performed during the session.
* **Demon Score:** Earn points based on workout duration and intensity to level up your daily score.

### 3. **Nutrition Command**

* **Macro Tracking:** Log meals with Calories, Protein, Carbs, Fats, and Fiber.
* **Fast Logging:** Quick-add common foods or create custom entries.
* **Totals:** Real-time visualization of daily macro consumption against targets.

### 4. **Body Metrics Analytics**

* **Data Visualization:** Interactive graphs tracking **Weight History** over time.
* **TDEE Calculator:** Automatic calculation of Total Daily Energy Expenditure based on profile.
* **Stats:** Track Body Fat %, BMI, and Max Caffeine tolerance.
* **Measurement Log:** Record waist, neck, chest, arms, and leg measurements.

### 5. **Dashboard & Analytics**

* **Live Metrics:** Real-time step counting and goal tracking (10k steps).
* **Streak System:** Tracks consecutive days of logging to build momentum.
* **Motivational Quotes:** Daily rotating stoic and high-performance quotes.
* **Quick Actions:** Jump straight to Zen Mode, Workout, or Logging.

### 6. **Zen Mode**

* **Breathing Visualizer:** Guided 4-7-8 breathing exercises with visual cues.
* **Thought Collection:** A distraction-free interface to "dump" thoughts and clear your mind.
* **Theme Aware:** Works perfectly in both Light and Dark modes.

### 7. **Security & Optimization**

* **Privacy First:** All data is stored locally using **SQLCipher Encrypted Database**.
* **Secure Storage:** Encryption keys managed via secure hardware storage (KeyStore/Keychain).
* **Optimized Build:** R8 Code Shrinking and Obfuscation enabled for release builds.
* **Performance:** Smart image caching for high-res photo logs.

---

## 🛠 Technical Stack

* **Framework:** Flutter (3.x)
* **State Management:** Provider pattern (Global ViewModels)
* **Database:** `sqflite_sqlcipher` (Encrypted SQLite)
* **Security:** `flutter_secure_storage`
* **Charts:** `fl_chart` for analytics
* **UI/UX:** Custom "Glassmorphism" components and dynamic **Light/Dark Theme** support.
* **Sensors:** `pedometer` for step counting.

---

## 📦 Setup & Deployment

### Prerequisites

* Flutter SDK (3.x+)
* Android SDK / Studio or Xcode (for iOS)

### 1. Clone & Dependencies

```bash
git clone https://github.com/ARJUN-RAJESH-24/DemonModeProtocol.git
cd DemonModeProtocol
flutter pub get
```

### 2. Run (Debug)

```bash
flutter run
```

### 3. Build for Release (Deployment Ready)

**Android (APK/Bundle):**

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

*Note: Release builds are obfuscated and optimized.*

---

## 🛡 Credits

**Built by Arjun Rajesh**
*for the bold and strong*

[github.com/ARJUN-RAJESH-24](https://github.com/ARJUN-RAJESH-24)

---

**Demon Mode Protocol** — *Outwork your doubts.*
