# Screen: Dashboard (`mobile-shell-dashboard`)

| | |
|---|---|
| **Figma node** | `9:1015` |
| **Figma URL** | [Open in Figma](https://www.figma.com/design/94kHVaHUtL5qOgMExfXBzF/The-Gravity-App---Designs?node-id=9-1015) |
| **Screenshot** | [mobile-shell-dashboard.png](../screenshots/mobile-shell-dashboard.png) |
| **Reference code** | [mobile-shell-dashboard.tsx](../reference/mobile-shell-dashboard.tsx) |
| **Flutter** | `lib/features/home/home_shell.dart` |

## Shell chrome

- Background: `#FAFAFA`
- **App header** (56px): white, bottom border `#E5E7EB`, 20px horizontal padding
  - Left: mountain icon 24px + **"IRON PEAK"** 16px bold (tenant brand name)
  - Right: notification bell in 36×36 `#FAFAFA` rounded square
- **Bottom nav**: white, top border, 5 tabs (Dashboard active in teal)

## Welcome row (20px padding)

- Avatar: 48×48 circle
- Greeting: "Hello, {name}" — 14px `#4B5563`
- Motto: **"Peak Level Performance"** — 18px bold `#111827`
- Streak badge: `#F0FDFA` pill, flame icon + count "12", 13px bold `#0D9488`

## Hero booking card (20px padding)

- Full-width card, 20px radius, dark image overlay `rgba(17,24,39,0.7)`
- **CONFIRMED** tag: `#0D9488` bg, 11px bold white uppercase
- Time: "6:00 PM Today" — 13px semibold white, top-right
- Class title: 22px extrabold white — "Power Hour: Strength & Conditioning"
- Coach row: 24px avatar + "Coach Marcus" 13px medium white
- Location: "Peak Studio 1" — 13px semibold `#D1FAE5`

## Popular classes section

- Header: "Popular Classes This Week" 16px bold + "See All" 13px semibold `#0D9488`
- Horizontal scroll of class cards (240px wide each):
  - White card, 16px radius, 1px `#E5E7EB` border
  - Image: 120px height, 12px radius
  - Title: 15px bold `#111827`
  - Meta: 12px `#4B5563` — "Tomorrow • 8:30 AM • 45 min"

## Bottom navigation

| Tab | Active color |
|-----|--------------|
| Dashboard | `#0D9488` (icon + label semibold 10px) |
| Schedule, Bookings, Community, Profile | `#9CA3AF` (medium 10px) |

## Differences from current Flutter

- [ ] Add app header with tenant brand + notification bell
- [ ] Replace placeholder dashboard with hero booking card
- [ ] Add horizontal "Popular Classes" scroller
- [ ] Add streak badge in welcome row
- [ ] Match nav label sizes (10px) and colors
