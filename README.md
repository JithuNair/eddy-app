# eddy

> *A calm pocket inside turbulent water.*

**eddy** is an open-source ADHD companion app built by someone with a high-functioning ADHD profile, for the community. Not another productivity tool — built around how ADHD brains actually work.

---

## Why eddy exists

Most mental health and focus apps are built for neurotypical consistency: streaks, perfect records, daily reminders that feel like guilt. None of them account for dysregulation, hyperfocus cycles, dopamine crashes, or the all-or-nothing streak problem that makes ADHD users abandon apps entirely.

eddy is built around the ADHD nervous system. Regulation first. Productivity second. No punishment, no broken chains, no starting over.

---

## MVP Features

### 🌬 Regulate
Tools to calm a dysregulated nervous system fast. No 3-screen navigation. Open the app and you're already there.

- **Physiological Sigh** — double inhale through the nose, long slow exhale. Offloads CO₂ faster than any other breath pattern. Fastest acting for acute spikes.
- **Box Breathing** — 4·4·4·4. Structured, rhythmic, proven.
- **5-4-3-2-1 Grounding** — sensory anchoring. Breaks dissociation fast.

### ⏱ Focus *(coming soon)*
A hyperfocus session timer built around ADHD attention patterns. Not a Pomodoro clone — intervals based on ADHD research, not arbitrary 25-minute blocks. Set your intention before you start. No guilt if you exit early.

### 🌱 Momentum *(coming soon)*
Streak-free habit tracking. The only rule: **never two days missed in a row.** One missed day is allowed and expected. Two in a row is the only threshold. No streaks, no broken chain anxiety, no starting over from zero.

---

## Design Philosophy

- **Minimal friction** — dysregulated people won't navigate three screens
- **Dark mode first** — ADHD brains are often light-sensitive
- **No shame notifications** — reminders that don't feel like pressure
- **Fast, snappy UI** — slow apps lose ADHD users immediately
- **Regulation before productivity** — you can't focus if you're dysregulated

---

## Tech Stack

- **Flutter** — iOS + Android from a single codebase
- **Riverpod** — state management
- **go_router** — navigation
- **Hive** — local-first habit storage (no account required)
- **flutter_animate** — fluid, calming animations

---

## Project Structure

```
lib/
├── core/
│   ├── theme/          # Colors, typography, dark-mode-first design system
│   ├── widgets/        # Shared components (nav bar, etc.)
│   └── router.dart     # App routing
├── features/
│   ├── regulate/       # Breathing and grounding tools
│   ├── focus/          # Hyperfocus session timer
│   └── momentum/       # Streak-free habit tracking
└── main.dart
```

---

## Getting Started

```bash
# Requires Flutter 3.x+
git clone https://github.com/jithunair/eddy-app.git
cd eddy-app
flutter pub get
flutter run
```

---

## Contributing

eddy is open source and community built. You can contribute:

- New regulation techniques (research-backed)
- Ambient sound packs
- Localization (Hindi, Malayalam planned first)
- Focus mode variations
- UI/UX improvements
- Accessibility improvements

**No streak pressure in contribution culture either.** Async, flexible, welcoming. Show up when you can.

Open a discussion on GitHub before building something large — not for gatekeeping, but to avoid duplicated effort.

---

## Roadmap

- [ ] **Momentum screen** — streak-free habit tracking
- [ ] **Focus screen** — ADHD-interval session timer
- [ ] **Ambient sounds** — brown noise, rain, café hum
- [ ] **Body doubling** — silent co-working sessions
- [ ] **Sleep onset tools**
- [ ] **RSD tools** — rejection sensitive dysphoria support
- [ ] **Hyperfocus queue** — capture obsessions without diving in
- [ ] **Energy check-ins** — lightweight, not clinical
- [ ] **Hindi + Malayalam localization**

---

## About

Built by [Jithu J. Nair](https://github.com/jithunair) — Manager of Data Science & AI, Hyderabad. Self-identified combined-type ADHD profile. Every feature comes from lived experience, not clinical theory.

The name *eddy* comes from fluid dynamics: a calm, stable pocket that forms inside turbulent flow. That's what this app is trying to be.

---

*Open source. No ads. No streak anxiety. Built for us.*
