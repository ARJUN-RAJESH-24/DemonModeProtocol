# Demon Mode Protocol

> *"Hard things, done daily."*

**Demon Mode Protocol** is a high-performance productivity and fitness ecosystem designed to force discipline and track progress. Built with **Flutter** and **Dart**, it combines fitness tracking, habit formation, and rigorous productivity tools into a unified "Demon Mode" experience.

---

## Key Features

### 1. **Daily Transformation Log**

* **Accountability Tracking:** Log water intake (with quick add/remove buttons), mood, and sleep.
* **Journal & Conquests:** Daily reflection prompts and a "Conquests" log to record small victories.
* **Custom Habits:** Define non-negotiables (e.g., "Creatine", "Reading", "Deep Work") and track them daily.
* **Physique Check:** Capture daily progress photos to visualize your physical transformation.

### 2. **Gym Mode (War Room)**

* **Session Tracking:** Real-time workout timer with "Active" and "Rest" states.
* **Dual Modes:** Toggle between **Gym/Strength** (Sets, Reps, Weight) and **Cardio/Run** (Distance, Energy, Pace).
* **Session Log:** Detailed history of every set performed during the session.
* **Demon Score:** Earn points based on workout duration and intensity to level up your daily score.

### 3. **Dashboard & Analytics**

* **Live Metrics:** Real-time step counting and goal tracking (10k steps).
* **Nutrition Summary:** At-a-glance view of Calories, Protein, Carbs, and Fats.
* **Streak System:** Tracks consecutive days of logging to build momentum.
* **Motivational Quotes:** Daily rotating stoic and high-performance quotes.

### 4. **Zen Mode**

* **Breathing Visualizer:** Guided 4-7-8 breathing exercises with visual cues.
* **Thought Collection:** A distraction-free interface to "dump" thoughts and clear your mind.
* **Theme Aware:** Works perfectly in both Light and Dark modes.

### 5. **Expert Hub**

* **Curated Knowledge:** Direct access to high-quality fitness content from trusted sources:
  * **Athlean-X** (Science-based training)
  * **Jeff Nippard** (Hypertrophy science)
  * **MuscleBlaze** (Nutrition & Supplements)

---

## Technical Stack

* **Framework:** Flutter (3.x)
* **State Management:** Provider pattern (Global ViewModels)
* **Database:** SQLite (`sqflite`) for local persistence
* **UI/UX:** Custom "Glassmorphism" components and dynamic **Light/Dark Theme** support.
* **Sensors:** `pedometer` for step counting.
* **Media:** `image_picker` for progress photos, `youtube_player_flutter` for Expert Hub.

---

## Setup & Installation

### Prerequisites

* Flutter SDK (3.x+)
* Android SDK / Studio

### 1. Clone & Dependencies

```bash
git clone https://github.com/your-repo/demon-mode.git
cd demon_mode
flutter pub get
```

### 2. Build & Run

Connect your Android device (Developer Mode enabled) and run:

```bash
flutter run
```

*Note: The app requests permissions for Activity Recognition (Steps), Camera, and Location on first launch. Please grant "Allow All".*

---

## Troubleshooting

* **"Steps not counting":** Ensure you have granted "Physical Activity" permissions. Steps may take a few seconds to sync from the OS sensor.
* **"Database issues":** If the app crashes on launch after an update, try uninstalling the old version to clear the SQLite database, then reinstall.

---

**Demon Mode Protocol** — *Outwork your doubts.*
