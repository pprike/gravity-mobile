# Screen: Sign In (`mobile-sign-in`)

| | |
|---|---|
| **Figma node** | `9:980` |
| **Figma URL** | [Open in Figma](https://www.figma.com/design/94kHVaHUtL5qOgMExfXBzF/The-Gravity-App---Designs?node-id=9-980) |
| **Screenshot** | [mobile-sign-in.png](../screenshots/mobile-sign-in.png) |
| **Reference code** | [mobile-sign-in.tsx](../reference/mobile-sign-in.tsx) |
| **Flutter** | `lib/features/auth/login_screen.dart` |

## Layout

- Full-screen white background (`#FFFFFF`)
- Vertical layout: branding header → form → pinned footer (sign-in button + support)
- Horizontal padding: **24px**

## Branding header

- Logo container: 64×64, `#F0FDFA` background, 18px radius
- Logo icon: 36×36 teal arrow-up mark
- Title: **"Welcome back"** — 24px extrabold `#111827`
- Subtitle: **"Sign in to your {tenant} account"** — 14px regular `#4B5563`
- Section padding: 40px top, 32px bottom

## Form fields

| Field | Label | Input height | Border |
|-------|-------|--------------|--------|
| Email | "Email Address" | 48px | 1px `#E5E7EB`, radius 12px |
| Password | "Password" | 48px | same + "Hide" toggle right-aligned `#0D9488` |

- Label: 13px semibold `#111827`
- Input text: 15px regular `#111827`
- Gap between fields: 20px
- **Forgot password?** link: 14px semibold `#0D9488`, right-aligned

> Note: Figma mock uses email+password only (no organization slug field). Gravity API requires tenant slug — keep as a field but style consistently.

## Primary CTA

- **Sign In** button: full width, 52px height, `#0D9488` bg, 14px radius
- Label: 16px bold white

## Footer

- Support text: 13px `#9CA3AF` — "Need help? Contact your gym management"
- Email link: 13px semibold underlined `#4B5563`
- iOS home indicator bar at bottom

## Differences from current Flutter

- [ ] Remove organization field from visible UI or move to advanced/settings (Figma has no org field)
- [ ] Add password show/hide toggle
- [ ] Add "Forgot password?" link
- [ ] Add gym support footer block
- [ ] Use white bg (not gradient) per Figma
- [ ] Logo mark in teal rounded square (not text-only "Gravity")
