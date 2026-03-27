# SearchAnyCars — Flutter Mobile Application Build Specification

> **CLAUDE.md** — Complete instructions for an AI coding agent to build and evolve the SearchAnyCars Flutter mobile application. This is the single source of truth for all implementation decisions.

---

## 1. PROJECT OVERVIEW

**App Name:** SearchAnyCars
**Tagline:** India's Trusted Used Car Platform
**Framework:** Flutter 3.41+ (Dart 3.11+)
**Targets:** Android (primary), iOS (secondary)
**Architecture:** Offline-first, loosely coupled with backend
**Design Language:** Cinematic Dark Luxury — deep charcoal blacks, warm gold accents, glass morphism, buttery-smooth animations
**Quality Bar:** The app must feel like a ₹1 crore luxury product. Think BMW iDrive meets Spinny meets Apple.

### What This App Does

SearchAnyCars is a used car broker marketplace that aggregates dealer inventory and presents a unified brand experience. The Flutter app connects to an **Express + SQLite backend** running on a **local network** (same WiFi). The backend also serves a React website — both clients share the same API.

### Key Architectural Principles

1. **STANDALONE FIRST** — App must launch, display content, and be fully navigable even without network connectivity. Mock data and cached data are first-class citizens, not afterthoughts.
2. **LOOSELY COUPLED** — The backend is a data source, not a hard dependency. The app uses a Repository pattern: UI never knows whether data comes from API, cache, or mock.
3. **NETWORK AWARE** — Detects connectivity, switches data sources seamlessly, shows non-intrusive offline indicators.
4. **NO BACKEND MODIFICATIONS** — The mobile app must work against the existing backend API as-is. No new endpoints, no schema changes.
5. **GRACEFUL DEGRADATION** — No crashes on timeout, no blank screens on error. Always show something useful.

---

## 2. BACKEND API REFERENCE

The backend is an Express.js server with SQLite (better-sqlite3), running on port **4000** on the local network. The mobile app discovers it via a user-configured server URL (e.g., `http://192.168.1.100:4000`).

### 2.1 Connection & Health

```
GET /api/health
Response: { "ok": true, "service": "searchanycars-api", ... }
```

Use this to verify connectivity on app launch and for periodic reconnection checks (every 30 seconds when disconnected).

### 2.2 Listings API (Public — No Auth Required)

#### GET /api/listings

Returns all car listings matching filters. **No pagination** — returns full result set.

**Query Parameters:**

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `search` | string | Free-text search across title, brand, model, location_city | `search=Hyundai` |
| `categoryId` | int | Filter by vehicle category | `categoryId=3` |
| `brand` | string | Exact brand match | `brand=Toyota` |
| `fuel_type` | string | Exact fuel type | `fuel_type=Diesel` |
| `transmission_type` | string | Exact transmission | `transmission_type=Automatic` |
| `ownership_type` | string | Exact ownership | `ownership_type=First` |
| `seller_type` | string | Exact seller type | `seller_type=Certified Dealer` |
| `location_city` | string | Comma-separated cities, partial match | `location_city=Mumbai,Delhi` |
| `model_year_min` | int | Minimum year | `model_year_min=2021` |
| `model_year_max` | int | Maximum year | `model_year_max=2024` |
| `listing_price_min` | int | Minimum price in INR | `listing_price_min=500000` |
| `listing_price_max` | int | Maximum price in INR | `listing_price_max=2000000` |
| `total_km_driven_max` | int | Maximum kilometers | `total_km_driven_max=50000` |
| `listing_status` | string | Filter by status | `listing_status=Active` |
| `is_splus` | int | S-Plus premium flag (0/1) | `is_splus=1` |
| `is_new_car` | int | New car flag (0/1) | `is_new_car=0` |
| `sortBy` | string | Sort order | `priceAsc`, `priceDesc`, or default (year DESC, created DESC) |

**Response:** Array of listing objects (see Listing Model below).

**SQL used by backend:**
```sql
SELECT l.*, c.name as category_name, c.slug as category_slug
FROM listings l
LEFT JOIN categories c ON c.id = l.category_id
WHERE {dynamic clauses}
ORDER BY {sortBy logic}
```

#### GET /api/listings/:id

Returns a single listing by ID.

**Response:** Single listing object, or `404 { message: "Listing not found" }`.

### 2.3 Listing Response Object (Critical — Map This Exactly)

The backend returns listing rows with JSON fields auto-parsed by `toListing()`:

```json
{
  "id": 1,
  "category_id": 3,
  "category_name": "SUV",
  "category_slug": "suv",
  "listing_code": "SAC-1001",
  "title": "2022 Hyundai Creta SX(O)",
  "brand": "Hyundai",
  "model": "Creta",
  "variant": "SX(O)",
  "model_year": 2022,
  "registration_year": 2022,
  "vehicle_type": "SUV",
  "body_style": "SUV",
  "exterior_color": "Polar White",
  "interior_color": "Black",
  "listing_price_inr": 1450000,
  "negotiable": 0,
  "estimated_market_value_inr": 1500000,
  "ownership_type": "First",
  "seller_type": "Certified Dealer",
  "registration_state": "Delhi",
  "registration_city": "New Delhi",
  "total_km_driven": 25432,
  "mileage_kmpl": 16.8,
  "engine_type": "1.5L Turbo Petrol",
  "engine_capacity_cc": 1482,
  "power_bhp": 158,
  "torque_nm": 253,
  "transmission_type": "Automatic",
  "fuel_type": "Petrol",
  "battery_capacity_kwh": null,
  "overall_condition_rating": 9,
  "service_history_available": 1,
  "airbags_count": 6,
  "infotainment_screen_size": "10.25\"",
  "location_city": "New Delhi",
  "location_state": "Delhi",
  "dealer_rating": 4.8,
  "inspection_status": "Completed",
  "inspection_score": 92,
  "listing_status": "Active",
  "featured_listing": 1,
  "is_splus": 0,
  "is_new_car": 0,
  "views_count": 342,
  "favorites_count": 67,
  "lead_count": 28,
  "promotion_tier": "Premium",
  "additional_notes": null,
  "images": ["/uploads/listings/2026/01/abc.jpg", ...],
  "interiorImages": [],
  "exteriorImages": [],
  "engineImages": [],
  "tireImages": [],
  "damageImages": [],
  "specs": {},
  "created_at": "2026-01-15T10:30:00.000Z",
  "updated_at": "2026-01-15T10:30:00.000Z"
}
```

**CRITICAL IMAGE NOTE:** The `images` array contains **relative paths** like `"/uploads/listings/2026/01/abc.jpg"`. The app MUST prepend the server base URL to build full URLs: `"http://192.168.1.100:4000/uploads/listings/2026/01/abc.jpg"`.

### 2.4 Categories & Filters (Public)

```
GET /api/categories
Response: [{ id, name, slug, vehicle_type, description }, ...]

GET /api/filter-definitions
Response: [{ id, key, label, type, options: [...] }, ...]

GET /api/category-filters/:categoryId
Response: [{ id, key, label, type, options: [...] }, ...]
```

**Seed categories:** Hatchback, Sedan, SUV, MUV, Coupe, Pickup, Luxury Sedan, Luxury SUV

**Filter definition keys:** brand, fuel_type, transmission_type, ownership_type, seller_type, listing_price_min, listing_price_max, model_year_min, model_year_max, total_km_driven_max, location_city, body_style, exterior_color

### 2.5 Site Configuration (Public)

```
GET /api/site-config
Response: {
  "site_name": "SearchAnyCars",
  "hero": { "title": "...", "subtitle": "..." },
  "trust_bar": [{ "icon": "...", "label": "...", "iconClass": "..." }, ...],
  "budget_brackets": [{ "label": "Under ₹2 Lakh", "min": 0, "max": 200000 }, ...],
  "body_types": [{ "name": "Hatchback", "icon": "...", "count": "..." }, ...],
  "fuel_types": [{ "name": "Petrol", "icon": "...", "count": "..." }, ...],
  "cities": [{ "name": "New Delhi", "slug": "new-delhi", "count": "1,200+", "image": "..." }, ...],
  "reviews": [{ "name": "...", "city": "...", "car": "...", "text": "...", "rating": 5 }, ...],
  "contact_info": { "phone": "...", "whatsapp": "...", "email": "...", "address": "..." }
}
```

### 2.6 Authentication API

Auth uses **HTTP-only cookies** for token storage. The backend sets `access_token` and `refresh_token` cookies on login/register.

```
POST /api/auth/login
Body: { "email": "...", "password": "..." }
Response: { "user": { "id", "email", "name", "role", "avatar_url" } }
Sets cookies: access_token (15min), refresh_token (7d)

POST /api/auth/register
Body: { "email": "...", "password": "...", "name": "..." }
Response: { "user": { "id", "email", "name", "role" } }

POST /api/auth/refresh
Uses refresh_token cookie (automatic token rotation)
Response: { "user": { "id", "email", "name", "role", "avatar_url" } }

POST /api/auth/logout
Clears cookies, deletes session
Response: 204 No Content

GET /api/auth/me (requires auth)
Response: { "user": { "id", "email", "name", "role", "avatar_url", "phone", "created_at" } }

POST /api/auth/forgot-password
Body: { "email": "..." }
Response: { "message": "If that email exists, a reset link has been sent." }

POST /api/auth/change-password (requires auth)
Body: { "currentPassword": "...", "newPassword": "..." }
Response: { "message": "Password changed successfully" }
```

**Rate limiting on auth endpoints:** 20 requests per 15 minutes (production), 100 (development).

**Default admin account:** `admin@searchanycars.com` / `admin123`

### 2.7 Image Upload (Admin Only)

```
POST /api/uploads/image
Auth: Admin required
Body: multipart/form-data, field "image", max 6MB
Response: { "url": "/uploads/listings/YYYY/MM/uuid-name.ext", "path": "...", "fileName": "..." }
```

Images stored at `{UPLOADS_DIR}/listings/YYYY/MM/{uuid}-{sanitized-name}.{ext}` and served statically via Express.

### 2.8 Server-Sent Events

```
GET /api/events
Protocol: text/event-stream
Events: { "type": "config-updated", "key": "..." }
```

**For mobile:** Skip SSE. Poll `/api/site-config` on app resume instead (SSE drains battery on mobile and doesn't survive background).

---

## 3. DESIGN SYSTEM

### 3.1 Color Palette (EXACT — Do Not Deviate)

```dart
class AppColors {
  // Backgrounds
  static const Color bg            = Color(0xFF0A0A0F);    // Near-black with slight blue tint
  static const Color bgCard        = Color(0xFF141420);    // Card/surface background
  static const Color bgCardHover   = Color(0xFF1A1A2E);    // Card hover/pressed state
  static const Color bgGlass       = Color(0xB8141420);    // Glass morphism — rgba(20,20,32,0.72)

  // Gold Accent System (brand identity)
  static const Color gold          = Color(0xFFD4A853);    // Primary gold — CTAs, prices, active
  static const Color goldLight     = Color(0xFFF0D78C);    // Gradient highlights
  static const Color goldDark      = Color(0xFFA17A2B);    // Gradient shadows
  static const Color accent        = Color(0xFFE8B940);    // Special highlights

  // Text Hierarchy
  static const Color textPrimary   = Color(0xFFF0EDE6);   // Headings — warm white
  static const Color textSecondary = Color(0xFF9A9AAE);   // Descriptions — muted lavender
  static const Color textMuted     = Color(0xFF5E5E72);   // Placeholders — deep muted

  // Borders
  static const Color border        = Color(0x1FD4A853);   // Gold-tinted — rgba(212,168,83,0.12)
  static const Color borderLight   = Color(0x0FFFFFFF);   // Subtle separator — rgba(255,255,255,0.06)

  // Semantic
  static const Color success       = Color(0xFF34D399);   // Inspection passed, verified
  static const Color danger        = Color(0xFFF87171);   // Wishlist heart, alerts
  static const Color info          = Color(0xFF60A5FA);   // Informational badges
  static const Color white         = Color(0xFFFAFAFA);   // Rarely used
}
```

### 3.2 Typography

**Font:** DM Sans via `google_fonts` package. No other fonts allowed.

| Usage | Size (dp) | Weight | Color | Letter Spacing |
|---|---|---|---|---|
| Screen title | 24–32 | 800 | textPrimary | 0 |
| Section heading | 18 | 700 | textPrimary | 0 |
| Car name (card) | 14 | 700 | textPrimary | 0 |
| Body text | 14–15 | 400 | textSecondary | 0 |
| Price (featured) | 32 | 800 | gold | 0 |
| Price (card) | 17–18 | 800 | gold | 0 |
| Meta/tags | 11–12 | 600 | textSecondary | 0.5–1 |
| Label (uppercase) | 11–13 | 600–700 | gold/textMuted | 1–4 |
| Badge text | 10 | 700 | gold | 0.5 |
| Nav label | 10 | 500(inactive)/700(active) | textMuted/gold | 0 |

### 3.3 Border Radius Scale

| Component | Radius (dp) |
|---|---|
| Cards (large) | 20–24 |
| Cards (medium) | 18 |
| Input fields | 16–18 |
| Buttons (large) | 18 |
| Buttons (small/chips) | 12 |
| Avatars/logos | 14–24 |
| Tags/badges | 6–8 |
| Progress bars | 2 |
| Dots/indicators | 50% (circle) |

### 3.4 Shadows & Elevation

```
Level 0 (flat):     none
Level 1 (card):     BoxShadow(color: rgba(0,0,0,0.2), blurRadius: 8, offset: Offset(0,2))
Level 2 (elevated): BoxShadow(color: rgba(212,168,83,0.15), blurRadius: 30, offset: Offset(0,8))
Level 3 (CTA):      BoxShadow(color: rgba(212,168,83,0.3), blurRadius: 30, offset: Offset(0,8))
Level 4 (modal):    BoxShadow(color: rgba(0,0,0,0.5), blurRadius: 60, offset: Offset(0,20))
```

### 3.5 Glass Morphism Standard

Used for: bottom tab bar, overlay badges on images, modal backgrounds.

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(radius),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      color: const Color(0xEB0A0A0F), // rgba(10,10,15,0.92) for nav bar
      // OR AppColors.bgGlass for lighter glass
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
    ),
  ),
)
```

### 3.6 Icon System

Use `lucide_icons` package (LucideIcons class). Default size: 20dp. Default color: textSecondary. Active: gold.

Required icons: `home`, `search`, `heart`, `user`, `arrowLeftRight` (compare), `filter`, `chevronRight`, `chevronLeft`, `star`, `fuel`, `gauge` (speed), `calendar`, `mapPin` (location), `bell`, `shield`, `checkCircle`, `car`, `phone`, `arrowRight`, `camera`, `plus`, `x`

### 3.7 Gradient Definitions

```dart
// Primary CTA gradient (gold button)
LinearGradient(colors: [AppColors.gold, AppColors.goldLight, AppColors.gold], begin: Alignment.topLeft, end: Alignment.bottomRight)

// Hero banner gradient
LinearGradient(colors: [Color(0xFF1A1428), Color(0xFF0F1A2E), Color(0xFF0A1520)], begin: Alignment.topLeft, end: Alignment.bottomRight)

// Avatar gradient
LinearGradient(colors: [AppColors.gold, AppColors.goldDark], begin: Alignment.topLeft, end: Alignment.bottomRight)

// Gold subtle background (trust section, price card)
LinearGradient(colors: [AppColors.gold.withValues(alpha: 0.06), AppColors.gold.withValues(alpha: 0.02)], begin: Alignment.topLeft, end: Alignment.bottomRight)
```

---

## 4. RESPONSIVE DESIGN

### 4.1 Base Reference

The design reference is 393×852px (iPhone 15 Pro). All pixel values in this document are in reference dp. The app MUST scale across all devices.

### 4.2 Scaling Utilities (lib/utils/responsive.dart — EXISTS)

```dart
class Responsive {
  static const double _baseWidth = 393;
  static const double _baseHeight = 852;

  static double wp(double size);   // Scale by width ratio
  static double hp(double size);   // Scale by height ratio
  static double fp(double size);   // Font scale, capped at 1.3x
  static double get screenPadding; // 5.5% of screen width (~24dp)
  static double get featuredCardWidth; // 56% of screen width
}
```

### 4.3 Key Responsive Rules

- **Screen horizontal padding:** `screenWidth * 0.055` (never hardcoded 24dp)
- **Featured car card width:** `screenWidth * 0.56`
- **Car card image height:** 130dp (fixed — scales via wp() if needed)
- **List thumbnails:** 110×85dp
- **Bottom tab bar height:** 84dp + SafeArea bottom padding
- **Brand chips:** minWidth 76dp
- **All scrollable content:** `paddingBottom: 100dp` (clears tab bar)

### 4.4 Device Breakpoints

| Category | Width | Notes |
|---|---|---|
| Small phones | 320–359dp | Tighter spacing, smaller cards |
| Standard phones | 360–399dp | Base design (reference) |
| Large phones | 400–430dp | More breathing room |
| Phablets/tablets | 431–768dp | Cap font scaling at 1.3x |

---

## 5. APP ARCHITECTURE

### 5.1 Folder Structure (Current + Planned Additions)

```
lib/
├── main.dart                          # App entry: ProviderScope, MaterialApp.router, dark theme
├── router.dart                        # GoRouter: splash, onboarding, StatefulShellRoute (5 tabs), /car/:id
│
├── constants/                         # Design tokens (EXISTS)
│   ├── colors.dart                    # AppColors — all hex values
│   ├── typography.dart                # AppTypography — DM Sans text styles
│   ├── spacing.dart                   # AppSpacing (xs–xxxl) + AppRadius
│   └── animations.dart                # AppAnimations — duration constants
│
├── utils/                             # Utility functions (EXISTS)
│   ├── responsive.dart                # Responsive.wp(), hp(), fp(), screenPadding
│   ├── formatters.dart                # Formatters — price, km, EMI calculation
│   └── cache_manager.dart             # ** NEW ** Hive box read/write helpers with TTL
│
├── models/                            # Data models
│   ├── car.dart                       # Car, InspectionReport, DealerSummary (prototype model — KEEP)
│   ├── brand.dart                     # Brand (name, emoji, count)
│   ├── user.dart                      # AppUser (MODIFY: add fromJson/toJson)
│   ├── mock_data.dart                 # MockData — 8 cars, 8 brands, user, slides (KEEP as fallback)
│   ├── listing.dart                   # ** NEW ** Full backend Listing model with fromJson()
│   ├── category.dart                  # ** NEW ** Category model
│   ├── filter_definition.dart         # ** NEW ** Filter definition model
│   ├── site_config.dart               # ** NEW ** Site configuration model
│   └── auth_state.dart                # ** NEW ** Auth state (guest / authenticated user)
│
├── services/                          # ** NEW DIRECTORY ** — Network & data services
│   ├── interfaces/                    # Abstract service contracts
│   │   ├── car_service.dart           # abstract: getListings(), getListingById()
│   │   ├── auth_service.dart          # abstract: login(), register(), getCurrentUser(), logout()
│   │   └── config_service.dart        # abstract: getSiteConfig(), getConfigByKey()
│   ├── api/                           # Live API implementations (Dio)
│   │   ├── dio_client.dart            # Dio instance, interceptors, cookie jar
│   │   ├── api_car_service.dart       # Calls GET /api/listings, GET /api/listings/:id
│   │   ├── api_auth_service.dart      # Calls /api/auth/* endpoints
│   │   └── api_config_service.dart    # Calls GET /api/site-config, GET /api/categories
│   └── mock/                          # Offline implementations
│       └── mock_car_service.dart      # Returns MockData.cars (wraps existing mock data)
│
├── repositories/                      # ** NEW DIRECTORY ** — Decides API vs cache vs mock
│   ├── car_repository.dart            # Connected? → API + cache. Offline? → cache or mock.
│   ├── auth_repository.dart           # Auth flows with cookie management
│   └── config_repository.dart         # Config with 6-hour cache TTL
│
├── providers/                         # Riverpod state management
│   ├── app_provider.dart              # EXISTS — wishlist, search, compare (REWRITE to use repositories)
│   ├── connectivity_provider.dart     # ** NEW ** Server URL, connection state, health checks
│   ├── auth_provider.dart             # ** NEW ** Auth state: guest/authenticated
│   └── config_provider.dart           # ** NEW ** Site config, categories, filters
│
├── screens/                           # Screen widgets
│   ├── splash_screen.dart             # Animated brand reveal (EXISTS — ADD connectivity check)
│   ├── onboarding_screen.dart         # 3 slides (EXISTS — no changes needed)
│   ├── home_screen.dart               # 8 sections (EXISTS — REWRITE to use repositories)
│   ├── search_screen.dart             # Live search + filters (EXISTS — REWRITE for real API filters)
│   ├── car_detail_screen.dart         # Full car detail (EXISTS — REWRITE for full listing model)
│   ├── wishlist_screen.dart           # Saved cars (EXISTS — ADD Hive persistence)
│   ├── compare_screen.dart            # Car comparison (EXISTS — minor updates)
│   ├── profile_screen.dart            # User profile (EXISTS — ADD auth-aware rendering)
│   ├── main_shell.dart                # Tab scaffold with BottomTabBar (EXISTS)
│   ├── settings_screen.dart           # ** NEW ** Server URL configuration
│   ├── login_screen.dart              # ** NEW ** Email/password login
│   └── register_screen.dart           # ** NEW ** User registration
│
├── widgets/
│   ├── ui/                            # Reusable primitives (ALL EXIST)
│   │   ├── gold_button.dart           # Gold gradient CTA with scale animation
│   │   ├── glass_container.dart       # BackdropFilter blur wrapper
│   │   ├── badge_widget.dart          # Colored pill badge
│   │   ├── car_chip.dart              # Filter chip with scale animation
│   │   ├── section_header.dart        # "Title" + "See All" row
│   │   └── skeleton_loader.dart       # Shimmer placeholder
│   ├── car/                           # Car-specific widgets (ALL EXIST)
│   │   ├── car_card.dart              # Featured card (56% width, horizontal scroll)
│   │   ├── car_list_item.dart         # List row (thumbnail + info)
│   │   └── car_image.dart             # ** NEW ** CachedNetworkImage with gradient fallback
│   ├── navigation/
│   │   └── bottom_tab_bar.dart        # Custom glass morphism tab bar (EXISTS)
│   └── layout/
│       ├── screen_container.dart      # SafeArea + bg + padding wrapper (EXISTS)
│       └── offline_banner.dart        # ** NEW ** "Offline Mode" indicator banner
```

### 5.2 Tech Stack (pubspec.yaml)

```yaml
dependencies:
  flutter: sdk
  # Navigation
  go_router: ^15.1.2
  # State Management
  flutter_riverpod: ^2.6.1
  # UI & Design
  google_fonts: ^6.2.1
  lucide_icons: ^0.257.0
  shimmer: ^3.0.0
  flutter_animate: ^4.5.2
  # Storage
  shared_preferences: ^2.3.4
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  # Network
  dio: ^5.7.0
  cached_network_image: ^3.4.1
  dio_cookie_manager: ^3.1.1          # ** ADD ** for HTTP-only cookie auth
  cookie_jar: ^4.0.8                  # ** ADD ** persistent cookie storage
  # Utils
  intl: ^0.20.2
  connectivity_plus: ^6.1.4           # ** ADD ** network state detection
```

### 5.3 Navigation Structure (GoRouter — EXISTS)

```
GoRouter
├── / (SplashScreen)
├── /onboarding (OnboardingScreen)
├── StatefulShellRoute.indexedStack (MainShell + BottomTabBar)
│   ├── Branch 0: /home (HomeScreen)
│   ├── Branch 1: /search (SearchScreen)
│   ├── Branch 2: /compare (CompareScreen)
│   ├── Branch 3: /wishlist (WishlistScreen)
│   └── Branch 4: /profile (ProfileScreen)
├── /car/:id (CarDetailScreen — root navigator, NO tab bar)
├── /settings (SettingsScreen — ** NEW **)
├── /login (LoginScreen — ** NEW **)
└── /register (RegisterScreen — ** NEW **)
```

---

## 6. DATA MODELS

### 6.1 Listing Model (NEW — Maps to Backend Response)

```dart
class Listing {
  final int id;
  final int? categoryId;
  final String? categoryName;
  final String listingCode;
  final String title;
  final String brand;
  final String model;
  final String? variant;
  final int? modelYear;
  final int? registrationYear;
  final String? vehicleType;
  final String? bodyStyle;
  final String? exteriorColor;
  final double listingPriceInr;
  final bool negotiable;
  final double? estimatedMarketValueInr;
  final String? ownershipType;
  final String? sellerType;
  final String? registrationState;
  final double? totalKmDriven;
  final double? mileageKmpl;
  final String? engineType;
  final double? engineCapacityCc;
  final double? powerBhp;
  final String? transmissionType;
  final String? fuelType;
  final double? overallConditionRating;
  final bool serviceHistoryAvailable;
  final int? airbagsCount;
  final String? infotainmentScreenSize;
  final String? locationCity;
  final String? locationState;
  final double? dealerRating;
  final String? inspectionStatus;
  final double? inspectionScore;
  final String listingStatus;
  final bool featuredListing;
  final bool isSplus;
  final bool isNewCar;
  final int viewsCount;
  final int favoritesCount;
  final List<String> images;         // Relative paths from backend
  final List<String> interiorImages;
  final List<String> exteriorImages;
  final Map<String, dynamic> specs;
  final String? promotionTier;
  final String? additionalNotes;
  final String createdAt;
  final String updatedAt;

  // COMPUTED FIELDS (not from backend)
  String get priceFormatted { ... }     // "₹14.5L" or "₹1.2 Cr"
  String get kmFormatted { ... }        // "25,432 km"
  String get emiFormatted { ... }       // "₹21,500/mo" (80% loan, 10.5%, 48mo)
  String get ownerDisplay { ... }       // "First" → "1st", "Second" → "2nd"
  String get brandInitial { ... }       // brand[0].toUpperCase()
  bool get isCertified { ... }          // inspectionStatus == "Completed"
  String get badgeText { ... }          // Derive from promotionTier, isSplus, featuredListing

  // Build full image URLs by prepending server base URL
  List<String> imageUrls(String serverBaseUrl) {
    return images.map((path) => '$serverBaseUrl$path').toList();
  }

  factory Listing.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

### 6.2 Field Mapping: Backend → Display

| Backend Field | Display Field | Transform |
|---|---|---|
| `title` | Car name | Direct |
| `brand` | Brand name | Direct |
| `listing_price_inr` | Price | `1450000` → `"₹14.5L"` |
| `total_km_driven` | Kilometers | `25432` → `"25,432 km"` |
| `fuel_type` | Fuel | Direct |
| `transmission_type` | Transmission | Direct |
| `ownership_type` | Owner | `"First"` → `"1st"`, `"Second"` → `"2nd"` |
| `location_city` | City | Direct |
| `inspection_score` | Rating | `92` → display as score/100 |
| `overall_condition_rating` | Condition | 1-10 scale |
| `dealer_rating` | Dealer stars | Direct (0-5) |
| `images` (array) | Gallery URLs | Prepend server base URL |
| `featured_listing` (0/1) | Is featured | `1` → `true` |
| `promotion_tier` | Badge | `"Premium"`, `"Featured"`, `"Standard"` |
| EMI | EMI display | **Calculated client-side** (see below) |

### 6.3 EMI Calculation (Client-Side — Matches Website)

```dart
static String calculateEmi(double priceInr) {
  const loanPercent = 0.80;       // 80% of price
  const annualRate = 10.5;        // 10.5% per annum
  const tenureMonths = 48;        // 4 years

  final principal = priceInr * loanPercent;
  final monthlyRate = annualRate / 12 / 100;
  final factor = pow(1 + monthlyRate, tenureMonths);
  final emi = (principal * monthlyRate * factor) / (factor - 1);
  return '₹${NumberFormat('#,###', 'en_IN').format(emi.round())}/mo';
}
```

### 6.4 Price Formatting (Indian Number System — Matches Website)

```dart
static String formatPriceInr(double valueInr) {
  if (valueInr >= 10000000) {
    return '₹${(valueInr / 10000000).toStringAsFixed(1)} Cr';
  } else if (valueInr >= 100000) {
    return '₹${(valueInr / 100000).toStringAsFixed(1)} Lakh';
  } else {
    return '₹${NumberFormat('#,###', 'en_IN').format(valueInr.round())}';
  }
}

static String formatPriceCompact(double valueInr) {
  if (valueInr >= 10000000) return '₹${(valueInr / 10000000).toStringAsFixed(1)}Cr';
  if (valueInr >= 100000) return '₹${(valueInr / 100000).toStringAsFixed(1)}L';
  return '₹${(valueInr / 1000).toStringAsFixed(0)}K';
}
```

---

## 7. CONNECTIVITY & OFFLINE ARCHITECTURE

### 7.1 Server URL Discovery

The user configures the server URL via a Settings screen. Stored in `SharedPreferences` under key `server_base_url`.

- **No URL configured:** App runs in mock-data mode (uses MockData.cars)
- **URL configured + reachable:** App fetches live data, caches it
- **URL configured + unreachable:** App uses cached data, shows offline banner
- **URL configured + no cache + unreachable:** App uses mock data, shows offline banner

### 7.2 Connectivity State

```dart
enum ConnectivityStatus { unknown, connected, disconnected, reconnecting }
```

- On app launch: ping `/api/health` with 5-second timeout
- On success: `connected`, fetch fresh data
- On failure: `disconnected`, use cache/mock
- While disconnected: retry every 30 seconds
- On reconnect: silent background refresh, show "Back online" snackbar

### 7.3 Dio Client Configuration

```dart
final dio = Dio(BaseOptions(
  baseUrl: serverUrl,                    // e.g., "http://192.168.1.100:4000"
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 10),
  headers: {'Content-Type': 'application/json'},
));

// Interceptor chain:
// 1. CookieManager(PersistCookieJar())  — handles auth cookies automatically
// 2. ConnectivityInterceptor            — sets connected/disconnected state
// 3. CacheInterceptor                   — cache GET responses, serve on failure
// 4. LogInterceptor (debug only)
```

### 7.4 Cache Strategy (Hive)

| Hive Box | Key Pattern | TTL | Purpose |
|---|---|---|---|
| `listings_cache` | `"all"`, `"featured"`, `"search:{hash}"` | 1 hour | Cached listing arrays |
| `listing_detail_cache` | `"{listing_id}"` | 1 hour | Individual listing details |
| `categories_cache` | `"all"` | 24 hours | Vehicle categories |
| `site_config_cache` | `"{config_key}"` | 6 hours | Site configuration |
| `wishlist_box` | `"ids"` | Permanent | Wishlist listing IDs |
| `user_cache` | `"current"` | Until logout | Cached user profile |
| `settings_box` | `"server_url"`, `"onboarding_done"` | Permanent | App settings |

### 7.5 Repository Decision Logic

```dart
class CarRepository {
  Future<List<Listing>> getListings({Map<String, dynamic>? filters}) async {
    if (isConnected) {
      try {
        final listings = await apiCarService.getListings(filters: filters);
        await cache.saveListings(cacheKey, listings); // Update cache
        return listings;
      } catch (e) {
        return _fallback(cacheKey); // Network error → try cache
      }
    } else {
      return _fallback(cacheKey); // Offline → cache or mock
    }
  }

  Future<List<Listing>> _fallback(String cacheKey) async {
    final cached = await cache.getListings(cacheKey);
    if (cached != null) return cached;
    return MockCarService().getListings(); // Last resort: mock data
  }
}
```

---

## 8. AUTHENTICATION STRATEGY

### 8.1 Cookie-Based Auth (Primary Approach)

The backend uses HTTP-only cookies. Use `dio_cookie_manager` + `PersistCookieJar`:

```dart
final cookieJar = PersistCookieJar(storage: FileStorage(appDocDir.path + '/.cookies/'));
dio.interceptors.add(CookieManager(cookieJar));
```

Dio automatically:
- Stores `Set-Cookie` headers from login/register responses
- Sends stored cookies on subsequent requests
- PersistCookieJar survives app restarts

### 8.2 Auth Flow

1. **App launch** → Check if cookie jar has tokens → Call `GET /api/auth/me`
2. **If 200** → User authenticated, store user in state
3. **If 401** → Call `POST /api/auth/refresh` (cookie jar sends refresh token)
4. **If refresh 200** → New tokens set automatically, retry `/auth/me`
5. **If refresh fails** → Guest mode (clear cookie jar)

### 8.3 Guest vs Authenticated

Auth is **completely optional**. The app must work fully without login.

| Feature | Guest | Authenticated |
|---|---|---|
| Browse listings | Yes | Yes |
| Search & filter | Yes | Yes |
| View car detail | Yes | Yes |
| Wishlist | Local only (Hive) | Local only (same — no backend wishlist API) |
| Compare cars | Yes | Yes |
| Book test drive | Prompt to login | Yes |
| Contact dealer | Prompt to login | Yes |
| Profile | Show login button | Show user profile |

### 8.4 Fallback: Bearer Token (If Cookies Fail)

If HTTP-only cookies don't work reliably with Dio on mobile, add bearer token support:

1. Intercept login response, extract token from response body (requires backend modification)
2. Store in `flutter_secure_storage`
3. Attach as `Authorization: Bearer {token}` header

**Try cookie approach first. Only fall back to bearer tokens if cookies are unreliable.**

---

## 9. SCREEN SPECIFICATIONS

### 9.1 Splash Screen (EXISTS — lib/screens/splash_screen.dart)

**Current:** Animated brand reveal (SA logo, SEARCHANYCARS text, tagline, loading line) → navigates to /onboarding at 2800ms.

**Integration changes:** During the loading line animation phase (2000-2800ms), silently attempt:
1. Read saved server URL from SharedPreferences
2. If URL exists, ping `/api/health`
3. Set initial connectivity state (don't block navigation on this)

**No UI changes needed.** Connectivity result is consumed by providers after navigation.

### 9.2 Onboarding Screen (EXISTS — lib/screens/onboarding_screen.dart)

**No changes needed.** 3 slides, skip button, navigates to /home.

Save `onboarding_done: true` to SharedPreferences on completion. Splash should check this flag and skip onboarding for returning users (navigate directly to /home).

### 9.3 Home Screen (EXISTS — lib/screens/home_screen.dart)

**Current:** Uses MockData directly. 8 hardcoded sections.

**Integration changes — ALL sections must use repositories:**

| Section | Current Data Source | New Data Source |
|---|---|---|
| Header (greeting) | Hardcoded "Karthi" | `authProvider` → user name or "Guest" |
| Header (location) | Hardcoded "CHENNAI" | `authProvider` → user city, or site_config cities[0] |
| Search bar | Static | No change (navigates to /search) |
| Hero banner | Hardcoded text | `configProvider` → site_config.hero (title, subtitle) |
| Popular brands | MockData.brands | Derived from listings (unique brands with counts) OR site_config.body_types |
| Quick stats | Hardcoded "10K+" | `configProvider` → derive from site_config, or hardcode as marketing |
| Featured cars | `featuredCarsProvider` (mock) | `listingsProvider(featured: true)` → GET /api/listings?featured_listing=1 |
| Recently added | `recentCarsProvider` (mock) | `listingsProvider(sortBy: 'latest')` → GET /api/listings?sortBy=latest (take 4) |
| Trust section | MockData.trustItems | `configProvider` → site_config.trust_bar |

**Loading states:** Show SkeletonLoader widgets while data loads (shimmer on bgCard).

**Error states:** Show cached data if available, or mock data with subtle "Showing sample data" indicator.

### 9.4 Search Screen (EXISTS — lib/screens/search_screen.dart)

**Current:** Client-side filtering of MockData.cars with 6 static chips.

**Integration changes:**

1. **Search input** → Debounce 500ms, then call `GET /api/listings?search={query}&{filters}`
2. **Filter chips** → Load from `GET /api/categories` (vehicle types: Hatchback, Sedan, SUV, MUV, etc.) instead of static list. "All" chip is always first.
3. **Active filter** → Maps to `body_style` or `vehicle_type` query param
4. **Results** → Display Listing objects from API, mapped to CarListItem widget
5. **Sort** → Add sort option (Latest, Price Low→High, Price High→Low) mapping to `sortBy` param
6. **Empty state** → "No cars found" with search icon
7. **Offline search** → Filter cached listings locally (same logic as current prototype)

### 9.5 Car Detail Screen (EXISTS — lib/screens/car_detail_screen.dart)

**Current:** Finds car from MockData by ID, shows static specs grid and hardcoded inspection data.

**Integration changes (MAJOR REWRITE):**

1. **Data source** → `GET /api/listings/:id` via repository
2. **Image gallery** → Load real images from `listing.imageUrls(serverUrl)` using `CachedNetworkImage`. Fall back to brand initial gradient (current style) on error.
3. **Photo count** → `listing.images.length` instead of hardcoded "32 Photos"
4. **Pagination dots** → `listing.images.length` dots
5. **Title** → `listing.title`
6. **Certified badge** → Show only if `listing.inspectionStatus == "Completed"`
7. **Price card** → Format `listing.listingPriceInr` and calculate EMI client-side
8. **Specs grid** → Map from listing fields:
   - Driven: `listing.totalKmDriven` → formatted
   - Fuel: `listing.fuelType`
   - Trans: `listing.transmissionType`
   - Year: `listing.modelYear`
   - Owner: `listing.ownerDisplay`
   - City: `listing.locationCity`
9. **Inspection report** → Use `listing.inspectionScore` as overall score. Individual category breakdown is NOT in the backend, so either:
   - Show only overall score (single progress bar), OR
   - Generate proportional breakdown from overall score (approximate)
10. **Dealer info** → `listing.sellerType`, `listing.dealerRating`, `listing.locationCity`
11. **Book Test Drive** → If authenticated: show booking flow. If guest: prompt login.

### 9.6 Wishlist Screen (EXISTS — lib/screens/wishlist_screen.dart)

**Current:** In-memory list [1, 3] via Riverpod.

**Integration changes:**
- Persist wishlist IDs in Hive box `wishlist_box` under key `"ids"`
- On load: read IDs from Hive, fetch listing details from cache or API
- On toggle: update Hive immediately (optimistic)
- Empty state: unchanged (heart emoji + message)
- **No backend sync** (website also uses localStorage — matches behavior)

### 9.7 Compare Screen (EXISTS — lib/screens/compare_screen.dart)

**Minor changes:** Update to work with Listing model instead of Car model. Same UI, same comparison logic.

### 9.8 Profile Screen (EXISTS — lib/screens/profile_screen.dart)

**Current:** Shows hardcoded MockData.currentUser.

**Integration changes:**
- **If authenticated:** Show user data from `authProvider` (name, email, member since)
- **If guest:** Show login/register prompt instead of profile header
- Menu items remain the same (My Bookings, Saved Cars, etc.)
- Add "Server Settings" menu item → navigates to /settings
- Add "Logout" option (if authenticated)

### 9.9 Settings Screen (NEW)

```
Layout:
- Title: "Settings" (24dp, weight 800)
- Server Connection section:
  - Label: "Server Address"
  - Input: TextField with http://192.168.1.x:4000 placeholder
  - [Test Connection] button → pings /api/health
  - Status indicator: green dot "Connected" / red dot "Disconnected" / spinner "Testing..."
  - [Save] button → saves to SharedPreferences, reinitializes Dio client
- App Info section:
  - Version: "SearchAnyCars v1.0.0"
  - Cache: "Clear Cache" button → clears all Hive boxes
```

### 9.10 Login Screen (NEW)

```
Layout:
- Dark bg with subtle gold gradient at top
- Back button → pop
- Title: "Welcome Back" (28dp, weight 800)
- Subtitle: "Sign in to your account" (14dp, textSecondary)
- Email input: standard dark input, gold focus border
- Password input: obscured, eye toggle
- [Sign In] button: gold gradient, full width
- Error message: danger color text below button
- "Don't have an account? Register" link → /register
- "Forgot Password?" link → show info dialog (email-based reset via website)
```

### 9.11 Register Screen (NEW)

```
Same layout as login with:
- Title: "Create Account"
- Name input (optional)
- Email input
- Password input (min 6 chars)
- Confirm password input
- [Create Account] button
- "Already have an account? Sign In" link → /login
```

---

## 10. ANIMATIONS

### 10.1 Animation Library

Use `flutter_animate` package for declarative animations. Use Flutter's built-in `AnimationController` for interactive animations (press effects).

### 10.2 Global Configs (EXISTS — lib/constants/animations.dart)

```dart
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);   // Chip press, tab switch
  static const Duration normal = Duration(milliseconds: 500); // Content reveal
  static const Duration slow = Duration(milliseconds: 800);   // Splash phases
  static const Duration splash = Duration(milliseconds: 2800); // Total splash duration
  static const int staggerDelay = 80;                         // ms between list items
}
```

### 10.3 Micro-Interactions

| Interaction | Animation | Implementation |
|---|---|---|
| Card press | Scale to 0.97 (200ms) | AnimationController in CarCard |
| Chip press | Scale to 0.93 (150ms) | AnimationController in CarChip |
| Button press | Scale to 0.95 (200ms) | AnimationController in GoldButton |
| Heart toggle | Spring scale 1→1.3→1 + color | flutter_animate .scale() |
| List item appear | fadeIn + slideY (20→0) | `.animate().fadeIn().slideY()` with stagger |
| Brand chip appear | fadeIn with stagger (80ms) | `.animate().fadeIn(delay: i * 80ms)` |
| Skeleton shimmer | Horizontal gradient sweep | shimmer package |

### 10.4 Splash Animation Sequence

Phase 1 (300ms): Logo scale 0.5→1 + fade (800ms, elasticOut)
Phase 2 (1200ms): Brand name fadeIn + slideY (600ms)
Phase 3 (1500ms): Tagline fadeIn (600ms)
Phase 4 (2000ms): Loading line scaleX 0→1 (800ms)
End (2800ms): Navigate to /onboarding or /home

---

## 11. ANDROID CONFIGURATION

### 11.1 Cleartext Traffic (REQUIRED for Local Network HTTP)

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:usesCleartextTraffic="true"
    ...>
```

**This is REQUIRED.** Without it, Android blocks all HTTP requests (non-HTTPS), which means the app cannot connect to the local network backend.

### 11.2 Internet Permission

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Should already be present via Flutter defaults.

---

## 12. IMPLEMENTATION PHASES

### Phase 1: Infrastructure (Foundation Layer)

- [ ] Add new dependencies: `dio_cookie_manager`, `cookie_jar`, `connectivity_plus`
- [ ] Create `Listing` model with `fromJson()` / `toJson()` mapping ALL backend fields
- [ ] Create `Category`, `FilterDefinition`, `SiteConfig`, `AuthState` models
- [ ] Create Dio client with cookie manager and interceptor chain
- [ ] Create connectivity provider (server URL, health check, state machine)
- [ ] Create Hive cache manager (init boxes, read/write with TTL, clear)
- [ ] Add `android:usesCleartextTraffic="true"` to AndroidManifest.xml
- [ ] Create abstract service interfaces
- [ ] Build Settings screen (server URL input, test connection)

### Phase 2: Data Layer (Services + Repositories)

- [ ] Implement `ApiCarService` (GET /api/listings, GET /api/listings/:id)
- [ ] Implement `MockCarService` (wraps existing MockData)
- [ ] Implement `CarRepository` with connectivity-aware fallback logic
- [ ] Implement `ApiConfigService` (GET /api/site-config, GET /api/categories)
- [ ] Implement `ConfigRepository` with cache
- [ ] Update formatters.dart with INR formatting (lakhs/crores, Indian number system)
- [ ] Test data flow: API → model → cache → UI

### Phase 3: Screen Integration

- [ ] Rewrite HomeScreen to use repository providers (all 8 sections)
- [ ] Rewrite SearchScreen with real API filtering + debounce
- [ ] Rewrite CarDetailScreen for full Listing model + real images
- [ ] Add `CachedNetworkImage` widget (car_image.dart) with gradient fallback
- [ ] Add offline banner widget
- [ ] Persist wishlist in Hive
- [ ] Update ProfileScreen for auth-aware rendering
- [ ] Add loading skeletons to all data-dependent sections
- [ ] Add pull-to-refresh to Home and Search screens

### Phase 4: Authentication

- [ ] Implement `ApiAuthService` (login, register, me, refresh, logout)
- [ ] Implement `AuthRepository` with cookie jar management
- [ ] Create auth provider with guest/authenticated states
- [ ] Build LoginScreen
- [ ] Build RegisterScreen
- [ ] Add auth interceptor (auto-refresh on 401)
- [ ] Add login prompts to "Book Test Drive" and "Contact Dealer"
- [ ] Update Profile screen with real user data and logout

### Phase 5: Polish & QA

- [ ] Error states for all API-consuming screens
- [ ] Empty states with appropriate icons and messages
- [ ] Network error recovery (retry buttons)
- [ ] Test on real Android device with backend running
- [ ] Test offline mode (WiFi off)
- [ ] Test slow network (throttled connection)
- [ ] Test server IP change (update settings)
- [ ] Test auth token expiry and refresh
- [ ] Test app kill and relaunch (cache persistence)
- [ ] Verify `flutter analyze` → 0 issues
- [ ] Verify `flutter test` → all pass

---

## 13. EXISTING CODE REFERENCE

### 13.1 Current Providers (lib/providers/app_provider.dart)

These exist and work. They will be **rewritten** to use repositories but the provider names and state shapes should remain compatible to minimize UI changes:

```dart
wishlistProvider         → StateNotifier<List<int>>       // IDs of wishlisted cars
carsProvider             → Provider<List<Car>>            // All cars (will become AsyncValue<List<Listing>>)
featuredCarsProvider     → Provider<List<Car>>            // First 4 cars
recentCarsProvider       → Provider<List<Car>>            // Last 4 cars
wishlistedCarsProvider   → Provider<List<Car>>            // Wishlisted cars
searchProvider           → StateNotifier<SearchState>     // Query + active filter
filteredCarsProvider     → Provider<List<Car>>            // Filtered search results
selectedCarProvider      → StateProvider<Car?>            // Selected car for detail
compareCarsProvider      → StateNotifier<List<Car>>       // Cars in comparison
```

### 13.2 Current Widget Inventory

All widgets exist and are production-ready. During integration, they need to be updated to accept either `Car` (mock) or `Listing` (API) data. The cleanest approach is to update `CarCard` and `CarListItem` to accept a presentation model or update the `Listing` model to provide the same interface.

| Widget | File | Props | Notes |
|---|---|---|---|
| GoldButton | widgets/ui/gold_button.dart | onPressed, text, icon?, isFullWidth, height | Scale 0.95 on press |
| GlassContainer | widgets/ui/glass_container.dart | child, padding, borderRadius, color | BackdropFilter blur(20) |
| BadgeWidget | widgets/ui/badge_widget.dart | text, color, bgOpacity | Pill badge |
| CarChip | widgets/ui/car_chip.dart | label, isActive, onTap | Scale 0.93 on press |
| SectionHeader | widgets/ui/section_header.dart | title, actionText, onAction | "Title" + "See All" |
| SkeletonLoader | widgets/ui/skeleton_loader.dart | width, height, borderRadius | Shimmer animation |
| CarCard | widgets/car/car_card.dart | car, onTap, onWishlistTap | 56% width, reads wishlist |
| CarListItem | widgets/car/car_list_item.dart | car, onTap, onWishlistTap | Row layout, reads wishlist |
| BottomTabBar | widgets/navigation/bottom_tab_bar.dart | currentIndex, onTap | Glass morphism, 5 tabs |
| ScreenContainer | widgets/layout/screen_container.dart | child, useSafeArea, padding | Scaffold + SafeArea |

### 13.3 Current Screen Dimensions Reference

| Element | Size | Notes |
|---|---|---|
| Screen padding | 5.5% width | ~24dp on 393px screen |
| Tab bar height | 84dp + bottom safe area | Glass morphism |
| Tab icon container | 36×36dp, radius 12 | Gold bg when active |
| Search bar | height 56dp, radius 18 | Gold-tinted border |
| Featured card | 56% screen width | Horizontal scroll |
| Card image area | 130dp height | Gradient bg |
| List thumbnail | 110×85dp | Radius 14 |
| Brand chip | minWidth 76dp | Radius 18, emoji inside 44×44 circle |
| Header avatar | 42×42dp, radius 14 | Gold gradient |
| Notification bell | 42×42dp, radius 14 | 8dp red dot indicator |
| Car detail gallery | 300dp height | Full width |
| Back button (detail) | 40×40dp, radius 14 | Dark glass bg |
| Heart button | 32×32dp, radius 10 | Dark glass bg |
| Profile avatar | 80×80dp, radius 24 | Gold gradient + shadow |
| Menu icon container | 40×40dp, radius 12 | bgCard bg |
| CTA button | height 56dp, radius 18 | Gold gradient |
| Phone button | 56×56dp, radius 18 | bgCard bg, gold border |
| Onboarding circle | 160×160dp | 50% radius |
| Onboarding next btn | 60×60dp | Circle, gold gradient |
| Splash logo | 90×90dp, radius 24 | Gold gradient |

---

## 14. DO NOT

- Do NOT use fixed pixel widths for layout containers — use percentages and Responsive utilities
- Do NOT use any font other than DM Sans — no Inter, Roboto, Arial, or system fonts
- Do NOT use light/white backgrounds — this is a DARK THEME ONLY app
- Do NOT use the default Flutter BottomNavigationBar — the custom glass morphism tab bar exists
- Do NOT skip animations — they are core to the premium luxury feel
- Do NOT use inline styles — use consistent patterns (avoid random magic numbers)
- Do NOT hardcode the server URL — it must be user-configurable via Settings
- Do NOT hardcode user data — use auth state or mock data
- Do NOT ignore SafeArea insets — use MediaQuery padding
- Do NOT forget paddingBottom on scrollable content (100dp minimum to clear tab bar)
- Do NOT crash on network errors — always show cached data, mock data, or error states
- Do NOT block the UI on network requests — use AsyncValue loading states
- Do NOT make the app depend on the backend being available — standalone first
- Do NOT modify the backend API — the mobile app adapts to it, not the other way around
- Do NOT use `withOpacity()` — use `withValues(alpha: x)` (Flutter 3.41+ deprecation)
- Do NOT store sensitive tokens in SharedPreferences — use cookie jar or secure storage
- Do NOT skip the health check — it's the connectivity detection mechanism

---

## 15. QUALITY CHECKLIST

Before considering any phase complete, verify:

- [ ] `flutter analyze` returns 0 issues (not warnings, not infos — zero)
- [ ] `flutter test` passes all tests
- [ ] App launches to splash screen without errors
- [ ] Navigation between all tabs works
- [ ] Car detail screen opens from any car card/list item
- [ ] Wishlist toggle works and persists across app restarts
- [ ] Search filters return correct results
- [ ] Offline mode shows cached/mock data gracefully
- [ ] No `RenderFlex overflowed` errors on any screen
- [ ] All animations are smooth (no jank on scroll)
- [ ] Gold accent is used consistently (CTAs, prices, active states)
- [ ] Text hierarchy is correct (headings warm white, body muted lavender, tertiary deep muted)
- [ ] Images load with placeholder fallback on error
- [ ] A Mercedes-Benz owner would feel this app matches their taste
