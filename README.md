# 🛡 ShieldSense — AI-Powered Women's Safety App

> A real-time personal safety monitoring system that continuously analyzes conversational, emotional, and environmental signals to compute a **Predictive Safety Index (PSI)** and trigger context-aware emergency responses.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Riverpod-2.4-purple?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Status-Hackathon%20Demo-FF3366?style=for-the-badge"/>
</p>

---

## 🚨 The Problem

Women face safety threats in everyday situations — escalating arguments, unfamiliar environments, coercive interactions — with no real-time system to detect risk and alert help **before** it's too late. Existing safety apps are reactive (press a button). ShieldSense is **proactive**.

---

## 💡 The Solution

ShieldSense runs a continuous background risk engine that scores three signal channels in real time, computes a weighted **Predictive Safety Index (PSI)**, detects escalation trends, and automatically routes to the appropriate response — from a silent nudge all the way to a full emergency protocol.

---

## 📱 Demo Screenshots

> _Run the app and use the scenario buttons at the bottom to simulate each state._

| Setup | Safe Monitoring | Elevated Risk | Emergency |
|-------|----------------|---------------|-----------|
| Baseline calibration | PSI < 30, green gauge | PSI 60–80, caution banner | PSI > 80, SOS triggered |

---

## 🔁 How It Works — System Flowchart

```
Start
  └─► Baseline Setup (2s calibration)
        └─► Start Monitoring
              └─► [LOOP every 1.5s]
                    ├─ Conversational Risk Analysis  (40% weight)
                    ├─ Emotional Stress Detection    (40% weight)
                    └─ Environmental Risk Assessment (20% weight)
                          └─► Compute PSI Score (0–100)
                                └─► Is Risk Escalating?
                                      ├─ NO  → Continue Silent Monitoring
                                      └─ YES →
                                            ├─ Moderate (40–60) → ⚠️  Subtle Alert
                                            │                         Vibration + Relocate suggestion
                                            ├─ High     (60–80) → 🟠  Safety Prompt
                                            │                         "Are you safe?" + Contact trusted person
                                            └─ Critical (80–100) → 🚨  Emergency Intervention
                                                                        Auto-alert contacts + Live location + Auto-call
```

---

## ⚙️ PSI Formula

```
PSI = (Conversational Risk × 0.40)
    + (Emotional Stress     × 0.40)
    + (Environmental Risk   × 0.20)
```

Each signal is sampled with ±6% random noise per cycle and smoothed with a **60/40 exponential decay filter** to prevent jitter and simulate realistic sensor variance.

**Escalation** is detected when PSI trends upward by more than 8 points across the last 3 consecutive readings.

---

## 🗂 Project Structure

```
lib/
├── main.dart                      # App entry point, GoRouter, Riverpod scope
├── models/
│   └── risk_model.dart            # RiskLevel, MonitoringState, PSISnapshot, RiskSignal
├── engine/
│   └── risk_engine.dart           # Core flowchart logic as Riverpod StateNotifier
├── screens/
│   ├── setup_screen.dart          # Animated baseline setup / splash screen
│   └── monitor_screen.dart        # Main 3-tab dashboard (Monitor / Signals / Log)
└── widgets/
    ├── psi_gauge.dart              # Custom arc ring gauge with animated glow
    ├── signal_card.dart            # Per-signal animated progress card
    ├── alert_banner.dart           # 3-branch alert UI (Subtle / Safety / Emergency)
    └── history_chart.dart          # fl_chart PSI history line graph
```

---

## 🧰 Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Frontend** | Flutter 3 + Dart | Cross-platform mobile UI |
| **State Management** | Riverpod 2 | Reactive risk engine state |
| **Navigation** | GoRouter | Clean routing + deep link support |
| **Charts** | fl_chart | PSI history visualization |
| **Risk Engine** | Custom Dart (simulation) | Weighted scoring + escalation detection |
| **Architecture** | StateNotifier + MVVM | Scalable, testable structure |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Android Studio / VS Code with Flutter extension
- Android device or emulator (API 21+)

### Run Locally

```bash
# 1. Clone the repository
git clone https://github.com/your-username/shield-sense.git
cd shield-sense

# 2. Install dependencies
flutter pub get

# 3. Run on connected device
flutter run
```

### Build APK

```bash
flutter build apk --release
```

---

## 🎮 Simulation Guide

The bottom bar exposes 4 scenario presets to demo each flowchart branch:

| Scenario | PSI Range | Triggered Response |
|---|---|---|
| **Normal** | 10 – 25 | ✅ Silent monitoring, green gauge |
| **Tense** | 45 – 60 | ⚠️ Subtle alert banner |
| **Suspicious** | 55 – 70 | 🟠 Safety prompt — check-in request |
| **Escalating** | 75 – 95 | 🚨 Emergency protocol — SOS active |

Each scenario injects ±6% noise per cycle so the gauge fluctuates naturally, just like real sensor input.

---

## 🔮 Roadmap — Production Integration

This hackathon build uses simulated signal values. The engine's `_runAnalysisCycle()` method is the single integration point for replacing simulation with real AI:

| Signal | Real Integration |
|---|---|
| **Conversational Risk** | Hugging Face toxicity / coercion NLP model via FastAPI |
| **Emotional Stress** | TensorFlow Lite voice stress model (MFCC + CNN) via WebRTC audio |
| **Environmental Risk** | GPS geofencing + safe zone radius via `geolocator` package |
| **Emergency Alerts** | Firebase Cloud Messaging + Twilio SMS |
| **Location Sharing** | Google Maps Platform live location |

---



## 📄 License

This project was built for hackathon demonstration purposes.  
MIT License — free to use, modify, and extend.

---

<p align="center">
  Built with ❤️ for women's safety · ShieldSense Hackathon 2026
</p>
