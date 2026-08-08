# Gravity Design Tokens (from Figma)

Source: [The Gravity App - Designs](https://www.figma.com/design/94kHVaHUtL5qOgMExfXBzF/The-Gravity-App---Designs) → **Design System** page (`0:1` / frame `3:22`)

## Color System

### Neutrals

| Token | Hex | Usage |
|-------|-----|-------|
| Background | `#FAFAFA` | Main canvas background |
| Surface | `#FFFFFF` | Card / panel surface |
| Border | `#E5E7EB` | Structural dividers |
| Text Primary | `#111827` | Headings, primary text |
| Text Secondary | `#6B7280` | Supporting text, labels |

### Brand (Teal — tenant swappable)

| Token | Hex | Usage |
|-------|-----|-------|
| Primary 50 | `#F0FDFA` | Subtle fills, badges, logo bg |
| Primary 100 | `#CCFBF1` | Light accents |
| Primary 600 | `#0D9488` | Primary buttons, active nav, links |
| Primary 700 | `#0F766E` | Hover / pressed states |
| Primary 800 | `#115E59` | Deep brand accent |

### Semantic

| Token | Hex | Usage |
|-------|-----|-------|
| Warning 100 | `#FEF3C7` | Warning background |
| Warning 500 | `#F59E0B` | Warning text/icon |
| Warning 700 | `#B45309` | Warning emphasis |
| Success | `#10B981` | Success states |
| Danger | `#EF4444` | Error / fully booked |

## Typography (Inter)

| Level | Size | Weight | Usage |
|-------|------|--------|-------|
| Display | 48px | Bold | Hero numbers |
| H1 | 30px | Semibold | Screen titles |
| H2 | 24px | Semibold | Section headers |
| H3 | 18px | Semibold | Subsection headers |
| Body | 16px | Regular | Primary readable text |
| Caption | 12px | Regular | Metadata, nav labels |

Mobile screens also use intermediate sizes from Figma exports: 10px (nav), 11px (badges), 13px (labels), 14px (body small), 15px (input text), 16px (buttons).

## Spacing

| Token | Value |
|-------|-------|
| xs | 4px |
| sm | 8px |
| md | 16px |
| lg | 24px |
| xl | 32px |
| 2xl | 48px |

## Radii

| Element | Radius |
|---------|--------|
| Input fields | 12px |
| Buttons (primary) | 14px |
| Cards | 16px |
| Hero booking card | 20px |
| Logo container | 18px |
| Day picker (selected) | 12px |
| Book action button | 10px |

## Mobile Shell Patterns

- **Frame width:** 390px (iPhone standard)
- **App header:** 56px height, white bg, bottom border `#E5E7EB`
- **Bottom nav:** 64px tab row + 34px home indicator area
- **Horizontal padding:** 20px (shell), 24px (auth)
- **Active tab:** `#0D9488` icon + label, semibold 10px
- **Inactive tab:** `#9CA3AF` icon + label, medium 10px

## Flutter Mapping

Implemented in `lib/core/theme/design_tokens.dart` and `lib/core/theme/app_theme.dart`.
