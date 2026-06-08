# Eddy — Design Assets

This folder contains the official brand direction and reference assets for the Eddy app.

---

## Founder-approved Eddy logo assets

The following files define the current, approved Eddy visual identity. They are the authoritative reference for all brand usage in and around the app.

| File | Purpose |
|---|---|
| `eddy_logo.png` | The universal Eddy symbol mark — the aquatic swirl "e". Use this for the in-app header logo and anywhere the standalone mark is needed. |
| `eddy_primary_lockup.png` | The primary logo + wordmark reference. Shows the approved proportions, spacing, and type style for the full brand lockup. |
| `eddy_app_icon_reference.png` | The app icon visual direction. Use this as the reference when generating platform-specific icon sizes (iOS, Android, web). |
| `eddy_brand_direction.png` | Earlier brand exploration reference (retained for historical context). |

These assets define the approved direction and **replace** the earlier CustomPainter-generated swirl logo as the primary brand visual.

---

## Usage in the app

The symbol mark (`eddy_logo.png`) is registered as a Flutter asset and used in `EddyBrandMark` (see `lib/core/widgets/eddy_swirl_logo.dart`).

The PNG is clipped to a soft rounded square in headers so it reads crisply on Eddy's dark surfaces. The "eddy" wordmark alongside it is rendered as a `Text` widget tinted by the section accent colour:

| Section | Accent |
|---|---|
| Regulate | Eddy Teal `#6FD3C0` |
| Focus | Drift Lavender `#A89BFF` |
| Momentum | Warm Coral `#FF8F7A` |

---

## Future asset guidance

When producing SVG, Lottie, or vector exports of the Eddy mark, preserve:

- The 3D volumetric aquatic wave form of the "e"
- The teal-to-lavender gradient (Eddy Teal `#6FD3C0` → Drift Lavender `#A89BFF`)
- The open counter of the letter (the white space inside the curl)
- The premium, calm, non-mascot character of the mark

Do not flatten the gradient to a single colour, add hard outlines, or introduce sharp geometry. The mark should always feel like water.

---

## Ownership

All brand assets in this folder are owned by **Jithu J. Nair** and are not open licensed. See [TRADEMARK.md](../../TRADEMARK.md) for the full brand policy.
