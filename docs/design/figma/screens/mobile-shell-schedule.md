# Screen: Schedule (`mobile-shell-schedule`)

| | |
|---|---|
| **Figma node** | `9:1086` |
| **Figma URL** | [Open in Figma](https://www.figma.com/design/94kHVaHUtL5qOgMExfXBzF/The-Gravity-App---Designs?node-id=9-1086) |
| **Screenshot** | [mobile-shell-schedule.png](../screenshots/mobile-shell-schedule.png) |
| **Reference code** | [mobile-shell-schedule.tsx](../reference/mobile-shell-schedule.tsx) |
| **Flutter** | `lib/features/home/home_shell.dart` |

## Shell chrome

Same app header and bottom nav as Dashboard, but **Schedule** tab is active (`#0D9488`).

## Day slider (white section, bottom border)

- Horizontal row of 7 day pills (M 15 … S 21)
- Each pill: 12px horizontal padding, 8px vertical
- Day letter: 11px semibold `#9CA3AF`
- Date number: 16px bold `#111827`
- **Selected day**: `#0D9488` bg, white text (e.g. T 18)

## Section header (20px padding)

- Title: **"Thursday's Classes"** — 18px bold `#111827`
- Filter: "All Studios" 13px semibold `#4B5563` + chevron-down 12px

## Class timeline cards (20px padding, 16px gap)

Each card: white, 16px radius, 1px `#E5E7EB` border, 16px internal padding.

| Column | Content |
|--------|---------|
| Time (70px) | Start time 13px bold + duration 11px `#9CA3AF` |
| Divider | 1px × 48px `#E5E7EB` |
| Details (flex) | Class name 15px bold, instructor 12px `#4B5563`, spots tag |
| Action (76px) | Book / Booked button |

### Spots tags

| State | Background | Text |
|-------|------------|------|
| Spots available | `#F0FDFA` | `#0D9488` 10px bold — "3 spots left" |
| Fully booked | `#FEF2F2` | `#EF4444` 10px bold — "Fully Booked" |

### Action buttons

| State | Style |
|-------|-------|
| Book | `#0D9488` bg, white 12px bold, 10px radius |
| Booked (disabled) | `#FAFAFA` bg, `#E5E7EB` border, `#9CA3AF` 12px semibold |

### Sample classes (from design)

1. 07:00 AM — Peak Pilates Flow — Sarah T. — 3 spots left — Book
2. 09:00 AM — Olympic Weightlifting — Marcus Vance — Fully Booked — Booked
3. 12:00 PM — Kettlebell Conditioning — Dave K. — 5 spots left — Book

## Differences from current Flutter

- [ ] Replace empty state with day slider + class timeline
- [ ] Implement class item card component
- [ ] Add studio filter dropdown
- [ ] Wire Book / Booked button states
