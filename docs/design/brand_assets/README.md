# Eddy — Brand Asset Pack

These are the founder-approved PNG brand assets for the Eddy app.

**PNG assets are the source of truth.** Do not replace them with CustomPainter-generated versions, SVG re-interpretations, or AI-regenerated alternatives. If an SVG export is needed in the future, convert the approved PNG using an external tool (e.g. Vectorizer.ai, Adobe Illustrator Live Trace) and verify the visual result preserves the shape, gradient, and premium aquatic feel.

---

## Asset inventory

### Brand / logo (`assets/brand/`)

| File | Used for |
|---|---|
| `eddy_logo.png` | In-app header logo mark — the aquatic swirl "e" symbol on transparent background |
| `eddy_primary_lockup.png` | Full logo + wordmark on transparent background (press kit, onboarding) |
| `eddy_primary_lockup_dark.png` | Full logo + wordmark optimised for dark surfaces |
| `eddy_app_icon.png` | App icon source — use as reference for generating platform icon sizes (iOS, Android, web) |
| `eddy_splash_mark.png` | Watermark/splash-screen version of the logo mark — large, centred, subtle |

### Theme toggle (`assets/icons/theme/`)

| File | Used for |
|---|---|
| `dark_mode_owl.png` | Shown in the top-right toggle button when the app is in **dark mode** — tapping switches to light |
| `light_mode_eagle.png` | Shown in the top-right toggle button when the app is in **light mode** — tapping switches to dark |

Both are wired in `lib/core/widgets/app_shell.dart` → `_ThemeToggle`.

### Bottom navigation icons (`assets/icons/nav/`)

| File | Tab |
|---|---|
| `regulate.png` | Regulate — nervous system / swirl brain icon |
| `focus.png` | Focus — crosshair / compass circle icon |
| `momentum.png` | Momentum — teal + coral wave "e" icon |

Wired in `lib/core/widgets/app_shell.dart` → `_NavBar`. Selected tab renders at full opacity; unselected at 35%.

### Regulate tool icons (`assets/icons/regulate/`)

Split from `grounded_breathing_icons.png` source sheet.

| File | Screen |
|---|---|
| `physiological_sigh.png` | Physiological Sigh tool card |
| `box_breathing.png` | Box Breathing tool card |
| `grounding.png` | 5-4-3-2-1 Grounding tool card |

Wired in `lib/features/regulate/screens/regulate_screen.dart` → `_RegulateCard.iconAsset`. White background removed; icons render cleanly on the subtle-coloured rounded container.

### Focus sound icons (`assets/icons/focus_sounds/`)

Split from `focus_background_icons.png` source sheet.

| File | Sound option |
|---|---|
| `none.png` | No ambient sound (muted) |
| `brown_noise.png` | Brown noise |
| `rain.png` | Rain |
| `cafe.png` | Café ambience |
| `vinyl.png` | 70s Vinyl |
| `music_stream.png` | Music stream |

Wired in `lib/features/focus/models/sound_option.dart` (`iconAsset` field) and `lib/features/focus/widgets/sound_picker.dart` (`_SoundChip`, `_StreamChip`). White background and baked-in label text removed; icons render at 22×22 inside chips.

### Illustrations (`assets/illustrations/`)

| File | Used for |
|---|---|
| `momentum_empty_state.png` | Empty state illustration for the Momentum screen (no habits yet) — wired in `_EmptyState` at 180px / 55% opacity |

---

## Source reference sheets

The original uncut sprite sheets are preserved in this folder:

| File | Contents |
|---|---|
| `app_nav_icons.png` | All 3 nav icons side by side |
| `grounded_breathing_icons.png` | All 3 regulate tool icons side by side |
| `focus_background_icons.png` | All 6 focus sound icons in a 2×3 grid |

---

## Ownership

All assets in this folder are owned by **Jithu J. Nair** and are not open licensed. See [TRADEMARK.md](../../../TRADEMARK.md) for the full brand policy.
