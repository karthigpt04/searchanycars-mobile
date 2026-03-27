# SearchAnyCars — Mobile Application Build Specification

> **claude.md** — Complete instructions for an AI coding agent to build the SearchAnyCars mobile application from the reference JSX prototype.

---

## 🎯 PROJECT OVERVIEW

**App Name:** SearchAnyCars
**Tagline:** India's Trusted Used Car Platform
**Platform:** React Native (Expo) — targeting iOS + Android
**Type:** Used car broker marketplace (aggregates dealer inventory, presents unified brand — modeled after Spinny/Cars24)
**Design Language:** Cinematic Dark Luxury — deep charcoal blacks, warm gold accents, glass morphism, buttery-smooth animations

### Reference File

The file `SearchAnyCars_Mobile_App.jsx` is a high-fidelity interactive React prototype. Use it as the **single source of truth** for:

- All color tokens, gradients, and opacity values
- Screen layouts, component hierarchy, and spacing
- Interaction patterns (navigation, wishlist toggle, search filtering)
- Animation timing and easing curves
- Icon set (inline SVG definitions for 20+ icons)
- Mock data structure (cars, brands, dealers)

**CRITICAL: The reference JSX uses fixed pixel widths (393×852 phone frame). The production app MUST be fully responsive across all mobile devices. See the Responsive Design section below.**

---

## 🎨 DESIGN SYSTEM

### Color Palette (EXACT — do not deviate)

```js
const Colors = {
  // Backgrounds
  bg:            '#0A0A0F',    // Primary app background — near-black with slight blue tint
  bgCard:        '#141420',    // Card/surface background
  bgCardHover:   '#1A1A2E',   // Card hover/pressed state
  bgGlass:       'rgba(20, 20, 32, 0.72)', // Glass morphism overlay

  // Gold Accent System (brand identity)
  gold:          '#D4A853',    // Primary gold — used for CTAs, prices, active states
  goldLight:     '#F0D78C',    // Light gold — gradient highlights
  goldDark:      '#A17A2B',    // Dark gold — gradient shadows, secondary gold
  accent:        '#E8B940',    // Accent gold — special highlights

  // Text Hierarchy
  textPrimary:   '#F0EDE6',   // Headings, car names, primary content — warm white
  textSecondary: '#9A9AAE',   // Descriptions, metadata — muted lavender
  textMuted:     '#5E5E72',   // Tertiary text, placeholders — deep muted

  // Borders
  border:        'rgba(212, 168, 83, 0.12)',  // Gold-tinted border for premium cards
  borderLight:   'rgba(255, 255, 255, 0.06)', // Subtle separator borders

  // Gradients (use as string values)
  gradient1:     'linear-gradient(135deg, #D4A853 0%, #F0D78C 50%, #D4A853 100%)',  // Primary CTA gradient
  gradient2:     'linear-gradient(180deg, #0A0A0F 0%, #141420 100%)',                // Vertical bg gradient
  gradient3:     'linear-gradient(135deg, #1A1A2E 0%, #0A0A0F 100%)',                // Card gradient

  // Semantic Colors
  success:       '#34D399',   // Inspection passed, verified badges
  danger:        '#F87171',   // Wishlist heart, alerts
  info:          '#60A5FA',   // Informational badges

  // Special
  white:         '#FAFAFA',   // Pure white (rarely used)
};
```

### Typography

- **Font Family:** `'DM Sans'` (Google Fonts) — primary for all text
- **Fallbacks:** `'SF Pro Display', -apple-system, BlinkMacSystemFont, sans-serif`
- **Load via:** `expo-google-fonts` or `@expo-google-fonts/dm-sans`

#### Type Scale

| Usage                  | Size (dp) | Weight | Color          | Letter Spacing |
|------------------------|-----------|--------|----------------|----------------|
| Screen title (large)   | 24–32     | 800    | textPrimary    | 0              |
| Section heading        | 18        | 700    | textPrimary    | 0              |
| Car name (card)        | 14        | 700    | textPrimary    | 0              |
| Body text              | 14–15     | 400    | textSecondary  | 0              |
| Price (featured)       | 32        | 800    | gold           | 0              |
| Price (card)           | 17–18     | 800    | gold           | 0              |
| Meta/tags              | 11–12     | 600    | textSecondary  | 0.5–1          |
| Label (uppercase)      | 11–13     | 600–700| gold/textMuted | 1–4            |
| Badge text             | 10        | 700    | gold           | 0.5            |
| Nav label              | 10        | 500/700| textMuted/gold | 0              |

### Border Radius Scale

| Component               | Radius (dp) |
|--------------------------|-------------|
| Full-screen modals       | 0           |
| Cards (large)            | 20–24       |
| Cards (medium)           | 18          |
| Input fields             | 16–18       |
| Buttons (large)          | 18          |
| Buttons (small/chips)    | 12          |
| Avatars/logos (square)   | 14–24       |
| Tags/badges              | 6–8         |
| Progress bars            | 2           |
| Dots/indicators          | 50% (circle)|

### Shadows & Elevation

```
Level 0 (flat):     none
Level 1 (card):     0 2px 8px rgba(0,0,0,0.2)
Level 2 (elevated): 0 8px 30px rgba(212,168,83,0.15)
Level 3 (CTA):      0 8px 30px rgba(212,168,83,0.3)
Level 4 (modal):    0 20px 60px rgba(0,0,0,0.5)
Level 5 (splash):   0 50px 100px rgba(0,0,0,0.6), 0 0 120px rgba(212,168,83,0.08)
```

### Glass Morphism Standard

Whenever using glass effect (nav bar, overlays, badges on images):

```css
background: rgba(10, 10, 15, 0.92);  /* or rgba(20, 20, 32, 0.72) for lighter glass */
backdrop-filter: blur(20px);
-webkit-backdrop-filter: blur(20px);
border-top: 1px solid rgba(255, 255, 255, 0.06);
```

### Icon System

Use `lucide-react-native` (or `react-native-vector-icons` Feather set). The reference JSX defines inline SVGs for these icons — replicate with the icon library:

`search`, `home`, `heart`, `heartFilled` (solid), `user`, `compare` (shuffle/arrows), `filter`, `chevronRight`, `chevronLeft`, `star` (solid), `fuel`, `speed` (gauge), `calendar`, `location` (map-pin), `bell`, `shield`, `check`, `car`, `transmission` (grid/cog), `camera`, `phone`, `arrowRight`

- Default icon size: 20dp
- Default icon color: `textSecondary`
- Active/accent icons use `gold`

---

## 📱 RESPONSIVE DESIGN (CRITICAL)

The reference JSX uses a fixed 393×852px phone frame for demo purposes. **The production app MUST be fully responsive.** Follow these rules:

### Layout Strategy

1. **Use percentage-based widths** for containers, NOT fixed pixel widths
2. **Use `Dimensions.get('window')` or `useWindowDimensions()`** for dynamic sizing
3. **Use `flex` layout** for all structural layout — never absolute pixel positioning for content
4. **Horizontal padding:** `5.5%` of screen width (≈ 24dp on 393px screen, scales to 20dp on 360px, 26dp on 430px)
5. **Bottom navigation height:** fixed 84dp with `paddingBottom: safeAreaInsets.bottom` added
6. **Status bar:** use `expo-status-bar` with `style="light"` — respect `SafeAreaView` on all screens

### Responsive Scaling Utilities

Create a `utils/responsive.ts` file:

```typescript
import { Dimensions, PixelRatio } from 'react-native';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

// Base design width (reference prototype)
const BASE_WIDTH = 393;
const BASE_HEIGHT = 852;

// Scale a value proportionally to screen width
export const wp = (size: number): number => {
  return PixelRatio.roundToNearestPixel((SCREEN_WIDTH / BASE_WIDTH) * size);
};

// Scale a value proportionally to screen height
export const hp = (size: number): number => {
  return PixelRatio.roundToNearestPixel((SCREEN_HEIGHT / BASE_HEIGHT) * size);
};

// Font scaling with upper limit to prevent massive text on tablets
export const fp = (size: number): number => {
  const scale = SCREEN_WIDTH / BASE_WIDTH;
  const clampedScale = Math.min(scale, 1.3); // Cap at 130% for readability
  return PixelRatio.roundToNearestPixel(size * clampedScale);
};

// Responsive value that uses width for horizontal, height for vertical
export const responsive = {
  padding: {
    screen: SCREEN_WIDTH * 0.055,  // ~24dp at 393px
    card: wp(14),
    section: wp(20),
  },
  borderRadius: {
    card: wp(20),
    button: wp(18),
    input: wp(16),
    chip: wp(12),
    avatar: wp(14),
    badge: wp(8),
  }
};
```

### Device Breakpoints

| Device Category     | Width Range  | Adjustments                                      |
|---------------------|-------------|--------------------------------------------------|
| Small phones        | 320–359dp   | Reduce card min-width, 2-col grids, smaller fonts |
| Standard phones     | 360–399dp   | Base design (reference)                           |
| Large phones        | 400–430dp   | Slightly larger cards, more breathing room         |
| Phablets/tablets    | 431–768dp   | 2-column car grids, wider content area, cap fonts |

### Safe Area Handling

```typescript
import { useSafeAreaInsets } from 'react-native-safe-area-context';

// In every screen component:
const insets = useSafeAreaInsets();

// Apply to:
// - Status bar area: paddingTop = insets.top
// - Bottom nav: paddingBottom = insets.bottom
// - Landscape: paddingLeft = insets.left, paddingRight = insets.right
```

### Scroll & Overflow

- All scrollable content uses `ScrollView` (vertical) or `FlatList` (lists)
- Horizontal scrollers (brands, featured cars): use `FlatList horizontal` with `showsHorizontalScrollIndicator={false}`
- Bottom nav and CTAs are absolutely positioned, content has `paddingBottom` to prevent overlap
- Use `contentContainerStyle={{ paddingBottom: 84 + insets.bottom }}` on all scrollable screens

### Image & Car Card Sizing

- **Featured car cards (horizontal scroll):** `width: SCREEN_WIDTH * 0.56` (≈220dp at 393px), never fixed
- **Car card image height:** `width * 0.59` (maintains aspect ratio)
- **List car thumbnails:** `width: wp(110)`, `height: wp(85)`
- **Brand chips:** `minWidth: wp(76)`, square with padding

---

## 🗂️ APP ARCHITECTURE

### Tech Stack

```
React Native (Expo managed workflow)
├── expo-router (file-based navigation)
├── expo-status-bar
├── react-native-safe-area-context
├── react-native-reanimated (animations)
├── react-native-gesture-handler
├── @expo-google-fonts/dm-sans
├── lucide-react-native (icons)
├── expo-linear-gradient
├── expo-haptics (tactile feedback)
├── expo-image (optimized image loading)
├── zustand (state management)
├── react-native-mmkv (local storage)
└── axios (API calls)
```

### Folder Structure

```
searchanycars/
├── app/                          # Expo Router screens
│   ├── _layout.tsx               # Root layout (SafeArea, fonts, theme)
│   ├── index.tsx                 # Splash screen (entry)
│   ├── onboarding.tsx            # Onboarding flow
│   ├── (tabs)/                   # Tab navigator group
│   │   ├── _layout.tsx           # Tab bar configuration
│   │   ├── home.tsx              # Home screen
│   │   ├── search.tsx            # Search screen
│   │   ├── compare.tsx           # Compare screen
│   │   ├── wishlist.tsx          # Wishlist screen
│   │   └── profile.tsx           # Profile screen
│   ├── car/
│   │   └── [id].tsx              # Car detail screen (dynamic route)
│   ├── dealer/
│   │   └── [id].tsx              # Dealer profile
│   ├── booking/
│   │   └── [carId].tsx           # Test drive booking flow
│   └── filters.tsx               # Full filter modal
├── components/
│   ├── ui/                       # Reusable UI primitives
│   │   ├── Button.tsx            # Gold gradient primary button
│   │   ├── Card.tsx              # Base card with dark bg, border
│   │   ├── Badge.tsx             # Status badges (Premium, Like New, etc.)
│   │   ├── Input.tsx             # Search input with icon
│   │   ├── Chip.tsx              # Filter chips (active gold / inactive dark)
│   │   ├── ProgressBar.tsx       # Inspection score bars
│   │   ├── GlassContainer.tsx    # Glass morphism wrapper
│   │   ├── IconButton.tsx        # Circle/rounded icon buttons
│   │   └── Skeleton.tsx          # Loading skeleton shimmer
│   ├── car/
│   │   ├── CarCard.tsx           # Featured car card (horizontal scroll)
│   │   ├── CarListItem.tsx       # List view car row (recently added)
│   │   ├── CarImageGallery.tsx   # Detail screen image carousel
│   │   ├── CarSpecs.tsx          # 3×2 spec grid
│   │   ├── InspectionReport.tsx  # Score card with progress bars
│   │   └── PriceCard.tsx         # Price + EMI display
│   ├── home/
│   │   ├── HeroBanner.tsx        # Promo banner with gradient
│   │   ├── BrandChips.tsx        # Horizontal brand scroller
│   │   ├── QuickStats.tsx        # 3-column stats row
│   │   ├── TrustSection.tsx      # Why SearchAnyCars section
│   │   └── SectionHeader.tsx     # "Title" + "See All" row
│   ├── navigation/
│   │   ├── BottomTabBar.tsx      # Custom tab bar (glass morphism)
│   │   └── StatusBar.tsx         # Custom status bar handler
│   └── layout/
│       ├── ScreenContainer.tsx   # SafeArea + background wrapper
│       └── ScrollContainer.tsx   # ScrollView with bottom padding
├── constants/
│   ├── colors.ts                 # Color palette (exact tokens from above)
│   ├── typography.ts             # Font sizes, weights, line heights
│   ├── spacing.ts                # Spacing scale
│   └── animations.ts            # Reanimated timing configs
├── hooks/
│   ├── useResponsive.ts          # wp(), hp(), fp() responsive helpers
│   ├── useWishlist.ts            # Wishlist add/remove/check
│   ├── useSearch.ts              # Search query + filter state
│   └── useAuth.ts                # User auth state
├── stores/
│   ├── useAppStore.ts            # Zustand global state
│   ├── useCarStore.ts            # Car data, filters, sort
│   └── useUserStore.ts           # User profile, preferences
├── services/
│   ├── api.ts                    # Axios instance + interceptors
│   ├── carService.ts             # Car listing endpoints
│   ├── dealerService.ts          # Dealer endpoints
│   ├── authService.ts            # Auth endpoints
│   └── bookingService.ts         # Test drive booking endpoints
├── utils/
│   ├── responsive.ts             # Responsive scaling utilities (see above)
│   ├── formatters.ts             # Price, km, date formatters
│   └── validators.ts             # Form validation
├── types/
│   ├── car.ts                    # Car, Brand, Filter types
│   ├── dealer.ts                 # Dealer types
│   ├── user.ts                   # User, Booking types
│   └── navigation.ts             # Route param types
├── assets/
│   ├── images/                   # Car placeholder images, logos
│   ├── icons/                    # Custom SVG icons (if needed beyond lucide)
│   └── animations/               # Lottie files for splash, empty states
└── claude.md                     # This file
```

---

## 📱 SCREEN SPECIFICATIONS

### Screen 1: Splash Screen (`index.tsx`)

**Duration:** 2.8 seconds total
**Purpose:** Brand reveal animation → auto-navigate to Onboarding (first launch) or Home (returning user)

#### Animation Sequence

| Phase | Delay   | Element                    | Animation                                          |
|-------|---------|----------------------------|----------------------------------------------------|
| 1     | 300ms   | Logo mark (SA)             | Scale 0.5→1 + opacity 0→1 (spring, 0.8s)          |
| 2     | 1200ms  | Brand name "SEARCHANYCARS" | TranslateY 20→0 + opacity 0→1 (ease, 0.6s)        |
| 2b    | 1500ms  | Tagline                    | Opacity 0→1 (ease, 0.6s, 300ms delay)             |
| 3     | 2000ms  | Loading line               | Width 0→60dp (ease, 0.8s)                          |
| End   | 2800ms  | Navigate away              | Fade out entire screen                              |

#### Layout

- Full screen, centered vertically
- Background: `radial-gradient(ellipse at 50% 40%, rgba(212,168,83,0.08), #0A0A0F 70%)`
- Logo: 90×90dp rounded square (radius 24), gold gradient background, "SA" in bg color, 800 weight
- Logo glow animation: `drop-shadow` pulsing between 20px/0.3 opacity and 40px/0.6 opacity (2s infinite)
- Brand name: "SEARCH" (textPrimary) + "ANY" (gold) + "CARS" (textPrimary), 28dp, weight 800, spacing 2
- Tagline: "India's Trusted Platform", 12dp, textSecondary, uppercase, letter-spacing 4
- Loading line: 2dp height, gold color, centered, animates width

---

### Screen 2: Onboarding (`onboarding.tsx`)

**3 slides** with swipe/tap navigation

#### Slides Data

```typescript
const slides = [
  {
    emoji: '🔍', // Replace with Lottie or illustration in production
    title: 'Discover Your\nDream Car',
    description: 'Browse 10,000+ verified used cars from trusted dealers across India',
    accentColor: Colors.gold,
  },
  {
    emoji: '🛡️',
    title: '200-Point\nInspection',
    description: 'Every car undergoes rigorous quality checks. Buy with complete confidence',
    accentColor: Colors.success,
  },
  {
    emoji: '💰',
    title: 'Best Price\nGuarantee',
    description: 'Transparent pricing with no hidden charges. Easy EMI options available',
    accentColor: Colors.info,
  },
];
```

#### Layout

- **Top right:** "SKIP" button (14dp, textSecondary, letter-spacing 1) → navigates to Home
- **Center (flex: 1):**
  - Illustration circle: 160×160dp, 50% radius, radial gradient with slide's accent color at 0.06 opacity
  - Float animation: translateY 0 → -12 → 0 (3s infinite ease-in-out)
  - Emoji/illustration: 72dp centered in circle
  - Title: 32dp, weight 800, textPrimary, center-aligned, `\n` for line breaks
  - Description: 16dp, textSecondary, center-aligned, 1.6 line-height, max-width 280dp
- **Bottom:**
  - Left: Pagination dots (3 dots, 8dp circles, active dot = 24dp wide gold pill, inactive = 8dp textMuted)
  - Right: Next button (60×60dp circle, gold gradient, arrowRight icon in bg color, shadow level 3)
  - Last slide: button triggers navigation to Home

---

### Screen 3: Home (`(tabs)/home.tsx`)

**The main screen. Most complex layout. Must scroll vertically.**

#### Section Order (top to bottom)

1. **Header** (non-scrollable sticky — or part of scroll)
   - Left: Location badge ("📍 CHENNAI", 13dp, textSecondary, letter-spacing 1) + Greeting ("Hello, **Karthi**" — name in gold, 22dp, weight 700)
   - Right: Notification bell (42×42dp, radius 14, bgCard bg, borderLight border, red 8×8dp dot at top-right) + Avatar (42×42dp, radius 14, gold gradient, initials "KM" in bg color, weight 700, 16dp)

2. **Search Bar** (tappable, navigates to Search screen)
   - Height 56dp, radius 18, bgCard bg, gold-tinted border
   - Left: search icon (gold), placeholder text "Search any car, brand, model..." (textMuted, 15dp)
   - Right: filter icon button (36×36dp, radius 12, gold at 0.1 opacity bg)

3. **Hero Banner** (promotional)
   - Radius 24, padding 24dp
   - Background: `linear-gradient(135deg, #1A1428, #0F1A2E 50%, #0A1520)`
   - Gold-tinted border
   - Decorative: radial gradient circle (140dp, gold at 0.12 opacity) positioned top-right
   - Content: "LIMITED TIME OFFER" label (11dp, gold, spacing 2, weight 600) → title "Zero Down Payment" (24dp, weight 800, textPrimary) → description (14dp, textSecondary) → CTA button (gold gradient, "Explore Offers" + arrowRight icon)
   - Background emoji: car emoji, 64dp, 0.15 opacity, bottom-right absolute

4. **Popular Brands** (horizontal scroll)
   - Section header: "Popular Brands" + "View All" (gold, 13dp)
   - Horizontal FlatList of brand chips
   - Each chip: min-width 76dp, padding 14×8dp, radius 18, bgCard bg, borderLight border
   - Chip content: circle container (44×44dp, radius 14, gold 0.06 opacity bg) with emoji (22dp) + brand name (11dp, textPrimary, weight 600)

5. **Quick Stats** (3-column row)
   - 3 equal-width cards, padding 16×12dp, radius 16, bgCard bg, borderLight border, center-aligned
   - Each: value (20dp, weight 800, gold) + label (11dp, textSecondary, margin-top 4)
   - Data: "10K+" Cars Listed, "200+" Dealers, "4.8★" Rating

6. **Featured Cars** (horizontal scroll)
   - Section header: "Featured Cars" + "See All"
   - Horizontal FlatList of CarCard components (first 4 cars)
   - Card: min-width 220dp (responsive: `SCREEN_WIDTH * 0.56`), radius 20, bgCard bg, borderLight border
   - Image area: 130dp height, gradient bg using car's color value, centered car emoji (56dp in prototype — use real images in production)
   - Badge: absolute top-left (10dp), padding 4×10, radius 8, gold 0.15 opacity bg + blur, text 10dp gold weight 700
   - Heart: absolute top-right (10dp), 32×32dp, radius 10, dark glass bg, heart icon (filled red if wishlisted)
   - Info: padding 14×16dp, car name (14dp, weight 700), specs line (11dp, textSecondary: "2022 • 18,200 km • Petrol"), price row: price (18dp, weight 800, gold) + EMI (10dp, textMuted)
   - `fadeUp` animation on mount with staggered delay (i × 100ms)
   - Scale 0.97 on press

7. **Recently Added** (vertical list)
   - Section header: "Recently Added" + "View All"
   - Vertical list of CarListItem components (cars 5–8)
   - Each: flexbox row, gap 14dp, padding 14dp, radius 18, bgCard bg, borderLight border, margin-bottom 12dp
   - Left: thumbnail (100×80dp, radius 14, gradient bg, centered emoji/image)
   - Right: car name (14dp, weight 700) + specs (11dp, textSecondary) + price row (16dp gold + badge chip)
   - `fadeUp` animation with staggered delay (i × 80ms)

8. **Trust Section** ("Why SearchAnyCars?")
   - Padding 20dp, radius 20, gold gradient bg at 0.06 opacity, gold-tinted border
   - Title: 16dp, weight 700, textPrimary
   - 4 rows, each: icon container (32×32dp, radius 10, gold 0.1 bg) + text (13dp, textSecondary), gap 12dp, spacing 12dp
   - Items: shield "200-Point Quality Inspection", check "5-Day Money Back Guarantee", car "Free Home Test Drive", phone "24/7 Customer Support"

---

### Screen 4: Search (`(tabs)/search.tsx`)

#### Layout

1. **Search Header:**
   - Back chevron + search input (flex row, gap 12dp)
   - Input: height 48dp, radius 16, bgCard bg, gold border, search icon (gold), text input (textPrimary, 14dp)
   - Live filtering as user types

2. **Filter Chips** (horizontal scroll, below search)
   - Chips: "All", "SUV", "Sedan", "Hatchback", "Luxury", "EV"
   - Active: gold bg, bg text color, gold border
   - Inactive: bgCard bg, borderLight border, textSecondary text
   - Padding 8×18dp, radius 12, 13dp weight 600, white-space nowrap

3. **Results Count** ("8 cars found", 12dp, textMuted)

4. **Results List** (vertical scrollable)
   - Same CarListItem component as Home "Recently Added"
   - Full list of filtered cars
   - Each card has location indicator: location icon (12dp, textMuted) + city name

---

### Screen 5: Car Detail (`car/[id].tsx`)

**No tab bar on this screen.** Full-screen immersive detail.

#### Layout

1. **Image Gallery** (height 300dp, absolute back/share buttons)
   - Background: vertical gradient from car's color to bg
   - Car image centered (120dp emoji → real image in production)
   - Back button: absolute top-left (20dp from edges), 40×40dp, radius 14, dark glass bg, chevronLeft icon
   - Wishlist heart: absolute top-right, same style, filled if wishlisted
   - Bottom: pagination dots (5 dots, active gold pill 20dp wide, inactive white 0.3 opacity 6dp circles)
   - Photo count badge: absolute bottom-right, camera icon + "32 Photos", dark glass bg, radius 8

2. **Scrollable Content** (below gallery, paddingBottom 100dp for CTA):

   a. **Title Area:**
      - "✓ Certified" badge (success bg 0.1, success text, 11dp weight 700, radius 8)
      - Car name (22dp, weight 800, textPrimary)
      - Year + owner info (13dp, textSecondary)

   b. **Price Card:**
      - Radius 20, gold gradient bg 0.08→0.02, gold border
      - Left: "ASKING PRICE" label (11dp, textSecondary, spacing 1) + price (32dp, weight 800, gold)
      - Right: "EMI from" label + EMI amount (16dp, weight 700, textPrimary)

   c. **Specs Grid** (3 columns × 2 rows):
      - Each cell: padding 14×10dp, radius 16, bgCard bg, borderLight border, center-aligned
      - Icon (18dp, gold) + value (13dp, weight 700, textPrimary) + label (10dp, textMuted)
      - Specs: Driven (km), Fuel, Transmission, Year, Owner, City

   d. **Inspection Report Card:**
      - Radius 20, bgCard bg, borderLight border, padding 20dp
      - Header: title (15dp, weight 700) + subtitle (12dp, textSecondary) | score badge (56×56dp, radius 16, success border, success bg 0.1, score value 18dp weight 800 success)
      - 4 progress bars:
        - Label (12dp, textSecondary) + percentage (12dp, weight 700, success)
        - Bar: 4dp height, radius 2, borderLight bg, fill with success gradient
        - Data: Engine 95%, Exterior 88%, Interior 92%, Tyres 85%

   e. **Dealer Info Card:**
      - Radius 20, bgCard bg, borderLight border, padding 20dp
      - Flex row: dealer avatar (48×48dp, radius 14, gold gradient, initial letter) + name/rating + chevronRight
      - Dealer name (14dp, weight 700), rating line (12dp, textSecondary: "⭐ 4.9 • Trusted Dealer • City")

3. **Bottom CTA Bar** (absolute bottom, gradient fade from transparent to bg 0.95):
   - Padding: 16dp horizontal 24dp, bottom 32dp
   - Call button: 56×56dp, radius 18, bgCard bg, gold border, phone icon (gold)
   - Book Test Drive button: flex 1, height 56dp, radius 18, gold gradient, "Book Test Drive" (16dp, weight 700, bg color), shadow level 3

---

### Screen 6: Wishlist (`(tabs)/wishlist.tsx`)

#### Layout

- Title: "Wishlist" (24dp, weight 800, textPrimary)
- Subtitle: "X saved cars" (13dp, textSecondary)
- List of wishlisted cars (CarListItem with heart toggle)
- Empty state: heart emoji (64dp), "No saved cars yet" (18dp, weight 700, textPrimary), "Tap the heart icon on cars you love" (14dp, textSecondary)

---

### Screen 7: Compare (`(tabs)/compare.tsx`)

#### Layout (Initial Empty State)

- Centered: scale emoji (56dp) + "Compare Cars" (20dp, weight 700, textPrimary)
- Description (14dp, textSecondary, center-aligned, padding 0 40dp)
- CTA: "Choose Cars" button (gold gradient, padding 12×28dp, radius 14)

#### Layout (With Cars Selected — IMPLEMENT THIS)

- 2–3 column comparison table
- Each column: car image, name, price at top
- Rows: Year, KM, Fuel, Transmission, Owner, City, Rating, EMI
- Highlight best value in each row with gold accent
- Add/remove car buttons at column tops

---

### Screen 8: Profile (`(tabs)/profile.tsx`)

#### Layout

1. **Profile Header** (radial gold gradient bg at 0.08 opacity):
   - Avatar: 80×80dp, radius 24, gold gradient, initials (28dp, weight 800, bg color), shadow level 3
   - Name: 20dp, weight 700, textPrimary, margin-top 16dp
   - "Member since 2024" (13dp, textSecondary)
   - Gold Member badge: inline-flex, star icon + "Gold Member" (12dp, weight 600, gold), gold bg 0.1, gold border, radius 10, padding 6×14dp

2. **Menu Items** (vertical list):
   - Each: flex row, gap 14dp, padding 16dp vertical, bottom border (borderLight)
   - Icon container (40×40dp, radius 12, bgCard bg, icon in gold)
   - Label (15dp, textPrimary, weight 500, flex 1)
   - Optional count badge (gold bg 0.1, gold text, weight 700, 12dp, radius 8)
   - ChevronRight icon (textMuted)
   - Items: My Bookings (2), Saved Cars (5), Compare History, Insurance & Warranty, Support Center, Notifications (3)

3. **Footer:** "SearchAnyCars v1.0.0" (12dp, textMuted, center)

---

## 🎭 ANIMATIONS

Use `react-native-reanimated` for all animations.

### Global Animation Configs

```typescript
import { withTiming, withSpring, Easing } from 'react-native-reanimated';

export const AnimConfig = {
  // Spring for bouncy entrances (splash logo, button presses)
  spring: { damping: 15, stiffness: 150, mass: 0.8 },

  // Smooth ease for content reveals
  ease: { duration: 500, easing: Easing.bezier(0.16, 1, 0.3, 1) },

  // Quick snap for tab switches, chip selections
  snap: { duration: 200, easing: Easing.ease },

  // Stagger delay base for list items
  staggerDelay: 80, // ms between each item
};
```

### Screen Transitions

- **Screen enter:** Slide up from bottom 30dp + fade in (500ms, ease)
- **Screen exit:** Fade out (200ms)
- **Tab switch:** Cross-fade (200ms)
- **Car detail enter:** Shared element transition on car image (if possible), otherwise slide up

### Micro-Interactions

| Interaction          | Animation                                    |
|---------------------|----------------------------------------------|
| Card press          | Scale to 0.97 (200ms ease)                   |
| Chip press          | Scale to 0.93 (150ms ease)                   |
| Heart toggle        | Spring scale 1→1.3→1 (spring) + color change |
| List item appear    | fadeUp (translateY 20→0 + opacity 0→1)       |
| Brand chip appear   | fadeUp with stagger                           |
| Scroll reveal       | Fade in as items enter viewport               |
| Button press        | Scale to 0.95 + haptic feedback (light)       |
| Pull to refresh     | Custom gold spinner                           |
| Skeleton loading    | Shimmer gradient animation (2s infinite)      |

### Splash Animation (Reanimated)

```typescript
// Phase-based timeline using delays
const logoScale = useSharedValue(0.5);
const logoOpacity = useSharedValue(0);
const textY = useSharedValue(20);
const textOpacity = useSharedValue(0);
const lineWidth = useSharedValue(0);

useEffect(() => {
  // Phase 1: Logo (300ms delay)
  setTimeout(() => {
    logoScale.value = withSpring(1, { damping: 12, stiffness: 100 });
    logoOpacity.value = withTiming(1, { duration: 800 });
  }, 300);

  // Phase 2: Text (1200ms delay)
  setTimeout(() => {
    textY.value = withTiming(0, { duration: 600, easing: Easing.bezier(0.16, 1, 0.3, 1) });
    textOpacity.value = withTiming(1, { duration: 600 });
  }, 1200);

  // Phase 3: Line (2000ms delay)
  setTimeout(() => {
    lineWidth.value = withTiming(60, { duration: 800 });
  }, 2000);
}, []);
```

---

## 🧭 NAVIGATION

### Navigation Structure

```
Root Stack Navigator
├── Splash Screen (index)
├── Onboarding Screen
├── Tab Navigator (main app)
│   ├── Home Tab
│   ├── Search Tab
│   ├── Compare Tab
│   ├── Wishlist Tab
│   └── Profile Tab
├── Car Detail (modal/push)
├── Dealer Profile (push)
├── Booking Flow (push)
└── Filters Modal (modal)
```

### Custom Tab Bar

The tab bar is a custom component (NOT default React Navigation tab bar):

- Height: 84dp + safe area bottom
- Background: `rgba(10, 10, 15, 0.92)` with `blur(20px)` backdrop filter
- Top border: `1px solid rgba(255,255,255,0.06)`
- 5 items equally spaced: Home, Search, Compare, Saved, Profile
- Each item: icon (20dp) inside container (36×36dp, radius 12) + label (10dp)
- Active state: gold icon, gold label (weight 700), icon container has gold bg at 0.12 opacity
- Inactive state: textMuted icon, textMuted label (weight 500), transparent container
- Transition: 200ms ease on all color/bg changes

---

## 📦 DATA MODELS

### Car

```typescript
interface Car {
  id: string;
  name: string;          // e.g., "Mercedes-Benz C-Class"
  brand: string;         // e.g., "Mercedes"
  model: string;         // e.g., "C-Class"
  year: number;
  price: number;         // in lakhs
  priceFormatted: string;// e.g., "32.5L"
  emi: string;           // e.g., "₹48,200/mo"
  km: number;
  kmFormatted: string;   // e.g., "18,200"
  fuelType: 'Petrol' | 'Diesel' | 'CNG' | 'Electric' | 'Hybrid';
  transmission: 'Automatic' | 'Manual';
  ownerNumber: string;   // e.g., "1st", "2nd"
  city: string;
  rating: number;        // 0–5 (inspection score)
  images: string[];      // Array of image URLs
  thumbnailUrl: string;
  badge?: string;        // "Premium", "Like New", "Trending", etc.
  color: string;         // Hex color for gradient backgrounds
  certified: boolean;
  dealer: DealerSummary;
  inspection: InspectionReport;
  specs: CarSpecs;
  createdAt: string;
}

interface CarSpecs {
  engine: string;        // e.g., "2.0L Turbo Petrol"
  power: string;         // e.g., "190 bhp"
  torque: string;        // e.g., "300 Nm"
  seats: number;
  bodyType: 'SUV' | 'Sedan' | 'Hatchback' | 'Luxury' | 'MUV' | 'Coupe';
  color: string;         // Exterior color name
  insurance: string;     // "Comprehensive" / "Third Party" / "Expired"
  registration: string;  // e.g., "MH02XX1234"
}

interface InspectionReport {
  overallScore: number;  // e.g., 4.8
  totalPoints: number;   // 200
  passed: boolean;
  categories: {
    name: string;        // e.g., "Engine & Transmission"
    score: number;       // 0–100
  }[];
}

interface DealerSummary {
  id: string;
  name: string;
  rating: number;
  city: string;
  badge: string;         // "Trusted Dealer"
  initial: string;       // First letter for avatar
}
```

### Brand

```typescript
interface Brand {
  id: string;
  name: string;
  logoUrl: string;
  carCount: number;
}
```

### User

```typescript
interface User {
  id: string;
  name: string;
  initials: string;
  email: string;
  phone: string;
  city: string;
  memberSince: string;
  tier: 'Bronze' | 'Silver' | 'Gold' | 'Platinum';
  wishlist: string[];    // Array of car IDs
  bookings: Booking[];
}
```

---

## 🔌 API ENDPOINTS (Design for Future Backend)

For initial build, use mock data matching the structures above. Design the service layer to be swappable:

```typescript
// services/carService.ts
export const carService = {
  getCarsList: (filters: CarFilters) => Promise<PaginatedResponse<Car>>,
  getCarDetail: (id: string) => Promise<Car>,
  getFeaturedCars: () => Promise<Car[]>,
  getRecentCars: () => Promise<Car[]>,
  searchCars: (query: string, filters: CarFilters) => Promise<Car[]>,
  getBrands: () => Promise<Brand[]>,
};
```

---

## ⚡ PERFORMANCE REQUIREMENTS

1. **Image loading:** Use `expo-image` with blur hash placeholders, progressive loading
2. **List rendering:** Use `FlatList` with `getItemLayout` for fixed-height items
3. **Skeleton screens:** Show shimmer loading states (gold-tinted shimmer on bgCard) while data loads
4. **Memoization:** `React.memo` on CarCard, CarListItem, BrandChip components
5. **Lazy loading:** Only load car detail data when navigating to detail screen
6. **Font loading:** Load DM Sans during splash screen, show splash until fonts ready
7. **Bundle size:** Use tree-shakeable icon imports from lucide

---

## ✅ IMPLEMENTATION CHECKLIST

### Phase 1: Foundation
- [ ] Expo project setup with TypeScript
- [ ] Install all dependencies
- [ ] Set up color tokens, typography, spacing constants
- [ ] Create responsive utilities (wp, hp, fp)
- [ ] Load DM Sans font
- [ ] Set up expo-router file structure
- [ ] Create ScreenContainer and ScrollContainer layouts

### Phase 2: Core Screens
- [ ] Splash screen with full animation sequence
- [ ] Onboarding with 3 slides + pagination + skip
- [ ] Home screen with all 8 sections
- [ ] Custom bottom tab bar (glass morphism)
- [ ] Search screen with live filter + chips

### Phase 3: Detail & Interaction
- [ ] Car detail screen with image gallery
- [ ] Inspection report with animated progress bars
- [ ] Wishlist functionality (add/remove/persist)
- [ ] Profile screen with menu

### Phase 4: Polish
- [ ] All micro-animations (fadeUp, scale, spring)
- [ ] Haptic feedback on interactions
- [ ] Skeleton loading states
- [ ] Pull-to-refresh
- [ ] Empty states (wishlist, search no results)
- [ ] Compare screen (full implementation)
- [ ] Error states and retry logic

### Phase 5: Responsive QA
- [ ] Test on iPhone SE (375dp width)
- [ ] Test on iPhone 15 Pro (393dp width)
- [ ] Test on iPhone 15 Pro Max (430dp width)
- [ ] Test on Pixel 7 (412dp width)
- [ ] Test on Samsung Galaxy S23 (360dp width)
- [ ] Test on Galaxy Z Fold (inner screen ~717dp)
- [ ] Verify safe area insets on all devices
- [ ] Verify landscape orientation (lock to portrait or support both)
- [ ] Test with system font scaling (accessibility)

---

## 🚫 DO NOT

- Do NOT use fixed pixel widths for layout containers
- Do NOT use Inter, Roboto, Arial, or system default fonts
- Do NOT use purple/blue gradient color schemes
- Do NOT use white/light backgrounds — the app is DARK THEME ONLY
- Do NOT use default React Navigation tab bar — build custom glass morphism tab bar
- Do NOT skip animations — they are core to the premium feel
- Do NOT use inline styles for repeated patterns — extract to StyleSheet.create
- Do NOT hardcode user data — use store/state management
- Do NOT ignore safe area insets
- Do NOT use `localStorage` or `AsyncStorage` for critical data — use `react-native-mmkv`
- Do NOT forget padding-bottom on scrollable content (tab bar overlaps otherwise)
- Do NOT use emoji for car images in production — use real car photos from API

---

## ✨ QUALITY BAR

The app should feel like a **₹1 crore luxury product**. Every interaction should feel deliberate, every transition butter-smooth, every color intentional. Think BMW iDrive meets Spinny meets Apple. The gold accent is the hero — use it sparingly but effectively to draw attention to prices, CTAs, and active states. The dark background isn't just aesthetic — it makes car images pop and creates cinema-screen focus.

When in doubt about any design decision, ask: **"Would a Mercedes-Benz owner feel this app matches their taste?"** If yes, proceed. If not, refine until it does.
