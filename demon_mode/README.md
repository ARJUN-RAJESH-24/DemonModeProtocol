# Demon Mode Protocol

> *"Hard things, done daily."*

**Demon Mode Protocol** is a high-performance productivity and fitness ecosystem designed to force discipline and track progress. Built with **Flutter** and **Dart**, it combines fitness tracking, habit formation, and rigorous productivity tools into a unified "Demon Mode" experience.

---

## Key Features

### 1. **Daily Transformation Log**
*   **Accountability Tracking:** Log your daily water intake, mood, and workout completions.
*   **Custom Habits:** Define your own non-negotiables (e.g., "Creatine", "Reading", "Deep Work") in Settings and track them daily.
*   **History View:** Review your past performance using the integrated calendar view.
*   **Photo Evidence:** Capture daily body check photos to visualize your transformation over time.

### 2. **Gym Mode (Workout Recorder)**
*   **Session Tracking:** Real-time workout timer and duration tracking.
*   **Set Logging:** Log exercises with Weight, Reps, and Sets. Automatically groups sets by exercise.
*   **Spotify Integration:** Control your music (Play/Pause/Skip) directly from the workout screen without leaving the app.
*   **GPS Tracking:** Tracks distance and pace for outdoor runs (beta).

### 3. **Zen Mode**
*   **Distraction Blocking:** A minimalist interface designed to lock you into flow state.
*   **Timer:** Dedicated focus timer for deep work sessions.

### 4. **Device Integration**
*   **Heart Rate Monitoring:** Connects to Bluetooth Low Energy (BLE) heart rate monitors (filtered by Service UUID `0x180D`) to display live BPM during workouts.

---

## Technical Stack

*   **Framework:** Flutter (Dark Mode first architecture)
*   **State Management:** Provider pattern (Global ViewModels)
*   **Database:** SQLite (`sqflite` with `sqlcipher` for security)
*   **Storage:** `shared_preferences` & `flutter_secure_storage`
*   **Music:** `spotify_sdk` (Custom Android App Remote integration)
*   **Design:** Custom "Glassmorphism" UI components (`GlassActionCard`)

---

## Setup & Installation

### Prerequisites
*   Flutter SDK (3.x+)
*   Android SDK / Studio
*   A Spotify Premium account (for Music control)
*   Spotify App installed on the device

### 1. Clone & Dependencies
```bash
git clone https://github.com/your-repo/demon-mode.git
cd demon_mode
flutter pub get
```

### 2. Spotify SDK Setup (Crucial)
This project requires the Spotify Android App Remote SDK, which is not available via standard Maven repositories. We have automated this process.

**Run the setup script (Windows):**
```powershell
./tools/setup_spotify_sdk.ps1
```
*This script will download the SDK, extract the AAR, and configure the local Gradle module.*

### 3. Build & Run
Connect your Android device (Developer Mode enabled) and run:
```bash
flutter run
```

---

## Screenshots

| Dashboard | Daily Log | Gym Mode |
|:---:|:---:|:---:|
| *(Screenshots to be added)* | *(Screenshots to be added)* | *(Screenshots to be added)* |

---

## Troubleshooting

*   **"Log loading forever":** If the database key gets corrupted (common on Android re-installs due to Auto Backup), the app tries to self-heal. Restart the app completely.
*   **"Spotify connection failed":** Ensure the Spotify app is open in the background and you are logged in.
*   **"Build failed":** Run `flutter clean` and ensure the `setup_spotify_sdk.ps1` script ran successfully.

---

**Demon Mode Protocol** — *Outwork your doubts.*
