# Figma Design Reference — Gravity Mobile

Canonical visual source for the member mobile app.

| | |
|---|---|
| **Figma file** | [The Gravity App - Designs](https://www.figma.com/design/94kHVaHUtL5qOgMExfXBzF/The-Gravity-App---Designs?node-id=3-12) |
| **File key** | `94kHVaHUtL5qOgMExfXBzF` |
| **Pulled** | 2026-08-07 |
| **Machine index** | [`figma-index.json`](figma-index.json) |

## Pages in file

| Page | Figma node | Contents |
|------|------------|----------|
| Design System | `0:1` → `3:22` | Colors, typography, spacing, components |
| Member Mobile App — Auth & Shell | `3:12` | Sign in, Dashboard, Schedule screens |

## Mobile screens (implemented in Figma)

| Screen | Node ID | Screenshot | Spec | Flutter target |
|--------|---------|------------|------|----------------|
| Sign In | `9:980` | [mobile-sign-in.png](screenshots/mobile-sign-in.png) | [spec](screens/mobile-sign-in.md) | `lib/features/auth/login_screen.dart` |
| Dashboard | `9:1015` | [mobile-shell-dashboard.png](screenshots/mobile-shell-dashboard.png) | [spec](screens/mobile-shell-dashboard.md) | `lib/features/home/home_shell.dart` |
| Schedule | `9:1086` | [mobile-shell-schedule.png](screenshots/mobile-shell-schedule.png) | [spec](screens/mobile-shell-schedule.md) | `lib/features/home/home_shell.dart` |

## Not yet in Figma

Bookings, Community, and Profile tab screens are referenced in the IA but do not have dedicated frames in this file yet. Use the shell patterns (header, bottom nav, spacing) from Dashboard/Schedule as the template.

## Design tokens

See [`design-tokens.md`](design-tokens.md) for the full color, typography, and spacing spec extracted from the Design System page.

## Reference code

`reference/` contains React+Tailwind exports from Figma MCP (`get_design_context`). These are **reference only** — adapt to Flutter using project widgets in `lib/core/widgets/` and tokens in `lib/core/theme/`.

## Re-syncing from Figma

When designs change, re-pull with the Figma MCP:

```
fileKey: 94kHVaHUtL5qOgMExfXBzF
nodeIds: 9:980, 9:1015, 9:1086, 3:22
```

Update screenshots, `figma-index.json`, and screen specs accordingly.
