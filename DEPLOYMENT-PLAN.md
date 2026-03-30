# SearchAnyCars — Global Deployment Plan

## Connecting the Flutter Mobile App to the Render Backend

---

## 1. CURRENT STATE

```
TODAY (Local Network Only)
==========================

    [Phone]                    [Laptop]
    Flutter App ──── WiFi ───→ Express:4000
    http://192.168.1.x:4000    SQLite + Uploads
                               React Website

    Problem: Only works on the same WiFi network.
```

```
GOAL (Global Access)
====================

    [Phone anywhere]           [Render Cloud]
    Flutter App ──── Internet ──→ https://searchanycars-app.onrender.com
                                  Express + DB + Uploads
    [Browser anywhere]             │
    React Website ─── Internet ────┘

    Result: Anyone in the world can use the website AND mobile app.
```

---

## 2. CONFLICTS ANALYSIS

### CONFLICT 1: SQLite on Render's Ephemeral Filesystem (CRITICAL)

**Problem:** Render's free/starter tier uses an ephemeral filesystem. Every deploy, restart, or auto-sleep wipes the disk. Your SQLite database file (`searchanycars.db`) gets **deleted** — all listings, users, bookings, favorites gone.

**Evidence:** `server/db.js` resolves `./searchanycars.db` relative to `process.cwd()`.

**Impact:** Total data loss on every deploy.

**Solutions (pick one):**

| Option | Cost | Effort | Recommendation |
|--------|------|--------|----------------|
| A. Render Persistent Disk | $0.25/GB/month | Low | Best for SQLite — attach a disk, set `DATABASE_PATH=/var/data/searchanycars.db` |
| B. Migrate to PostgreSQL | Free (Render) | High | Render offers free PostgreSQL. Requires rewriting all `db.prepare()` calls to use `pg` client |
| C. Use Turso (LibSQL cloud) | Free tier | Medium | Cloud-hosted SQLite. Change `better-sqlite3` to `@libsql/client`. Minimal SQL changes |
| D. Use SQLite + S3 backup | Free | Medium | Backup DB to S3 on every write, restore on boot. Fragile, not recommended |

**Recommended: Option A** (Persistent Disk) — zero code changes, just set an environment variable.

```
Render Dashboard → Your Service → Disks → Add Disk
  Mount Path: /var/data
  Size: 1 GB ($0.25/month)

Environment Variable:
  DATABASE_PATH=/var/data/searchanycars.db
```

---

### CONFLICT 2: Uploaded Images Lost on Deploy (CRITICAL)

**Problem:** Car images uploaded via `POST /api/uploads/image` are stored at `./uploads/listings/YYYY/MM/`. Ephemeral filesystem = images vanish.

**Evidence:** `server/storage.js` writes to `path.resolve(process.cwd(), uploadsDir, 'listings')`.

**Impact:** All car photos disappear on deploy/restart.

**Solutions (pick one):**

| Option | Cost | Effort |
|--------|------|--------|
| A. Same Persistent Disk | Included in $0.25/GB | Low |
| B. Cloudinary | Free (25GB) | Medium |
| C. AWS S3 | ~$0.023/GB | Medium |

**Recommended: Option A** — Store uploads on the same persistent disk:

```
Environment Variable:
  UPLOADS_DIR=/var/data/uploads
```

No code changes needed. Express already serves from `UPLOADS_DIR`.

---

### CONFLICT 3: Mobile App Uses HTTP, Render Uses HTTPS (HIGH)

**Problem:** The Flutter app connects to `http://192.168.1.x:4000` (HTTP). Render serves over `https://`. The app has `android:usesCleartextTraffic="true"` for local HTTP, but for Render it must use HTTPS.

**Evidence:** `DioClient.initialize(baseUrl)` accepts any URL. `connectivity_provider.dart` prepends `http://` if no scheme is given.

**Impact:** If user types the Render URL without `https://`, the app will try HTTP, which Render redirects to HTTPS — but Dio may not follow the redirect properly, causing connection failures.

**Fix required in mobile app:**

```dart
// In connectivity_provider.dart — setServerUrl()
// Current code:
if (!normalized.startsWith('http')) {
  normalized = 'http://$normalized';  // Always defaults to HTTP
}

// Fix: detect known cloud hosts and use HTTPS
if (!normalized.startsWith('http')) {
  if (normalized.contains('.onrender.com') ||
      normalized.contains('.railway.app') ||
      normalized.contains('.vercel.app') ||
      normalized.contains('.herokuapp.com')) {
    normalized = 'https://$normalized';
  } else {
    normalized = 'http://$normalized';  // Local network = HTTP
  }
}
```

---

### CONFLICT 4: Cookie Settings Won't Work Over HTTPS (HIGH)

**Problem:** Cookies are set with `secure: false` (default). Browsers and Dio will reject `Set-Cookie` with `secure: false` over HTTPS on Render.

**Evidence:** `authService.js` line 40: `secure: config.cookieSecure` defaults to `false`.

**Impact:** Login won't work — cookies get set but never sent back.

**Fix — Render environment variable:**

```
COOKIE_SECURE=true
```

**Also:** The `sameSite: 'lax'` setting works for same-origin (website). For the mobile app, Dio's `CookieManager` handles cookies differently than browsers — it stores them regardless of SameSite policy, so this is fine.

---

### CONFLICT 5: CORS Allows Everything (MEDIUM)

**Problem:** The CORS middleware allows all origins (even the `else` branch on line 19 of `security.js` says `callback(null, true)`). In production, this is a security risk.

**Evidence:** `security.js` lines 14-23.

**Impact:** Any website can make authenticated requests to your API.

**But for mobile apps:** CORS doesn't apply. Dio makes direct HTTP requests, not browser fetch. So CORS only matters for the website.

**Fix — Render environment variable:**

```
CORS_ORIGINS=https://searchanycars-app.onrender.com
```

**And fix the code bug** in `security.js`:

```javascript
// Current (broken — allows all):
} else {
  callback(null, true)  // BUG: should reject
}

// Fixed:
} else {
  callback(new Error('CORS not allowed'), false)
}
```

---

### CONFLICT 6: JWT Secrets Are Hardcoded Defaults (CRITICAL)

**Problem:** `config.js` has `'dev-access-secret-change-in-production-32chars!'` as the default JWT secret. Anyone who reads the source code (it's on GitHub) can forge admin tokens.

**Impact:** Complete authentication bypass — anyone can impersonate admin.

**Fix — Render environment variables:**

```
JWT_ACCESS_SECRET=<random-64-char-string>
JWT_REFRESH_SECRET=<different-random-64-char-string>
ADMIN_DEFAULT_PASSWORD=<strong-password>
```

Generate secrets:
```bash
node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"
```

---

### CONFLICT 7: Frontend URL Defaults to localhost (MEDIUM)

**Problem:** `config.js` falls back to `RENDER_EXTERNAL_URL` or `http://localhost:5173`. Email links (password reset, booking confirmation) will point to localhost if not configured.

**Evidence:** `config.js` line: `frontendUrl: process.env.FRONTEND_URL || process.env.RENDER_EXTERNAL_URL || 'http://localhost:5173'`

**Good news:** On Render, `RENDER_EXTERNAL_URL` is automatically set to `https://your-app.onrender.com`. So this self-fixes on Render without configuration.

---

### CONFLICT 8: Mobile App Server URL UX (LOW)

**Problem:** Users must manually type the server URL in Settings. For a global app, this is poor UX.

**Current flow:**
```
Install app → Open → See "No server configured" → Go to Settings → Type URL → Save
```

**Better flow:**
```
Install app → Open → App automatically connects to production backend
                   → Settings still available to override (for dev/testing)
```

**Fix:** Hardcode the Render URL as the default, let Settings override it:

```dart
// In connectivity_provider.dart
static const String _defaultServerUrl = 'https://searchanycars-app.onrender.com';

Future<void> _init() async {
  final savedUrl = CacheManager.getServerUrl();
  final url = (savedUrl != null && savedUrl.isNotEmpty) ? savedUrl : _defaultServerUrl;
  state = state.copyWith(serverUrl: url);
  await checkConnection();
}
```

---

### CONFLICT 9: Render Free Tier Spins Down After Inactivity (MEDIUM)

**Problem:** Render free tier services "sleep" after 15 minutes of no traffic. First request after sleep takes 30-60 seconds (cold start).

**Impact:** User opens app after idle period → sees "Connecting..." for 30+ seconds → thinks app is broken.

**Solutions:**

| Option | Cost |
|--------|------|
| Upgrade to Render Starter ($7/month) | No sleep, always on |
| Use a free uptime monitor (UptimeRobot) | Ping every 5 min, keeps alive |
| Show a "Waking up server..." message in the app | Free, better UX |

**Recommended:** Use UptimeRobot (free) to ping `/api/health` every 5 minutes AND increase the Dio connect timeout for the initial health check:

```dart
// In DioClient — increase initial connect timeout
connectTimeout: const Duration(seconds: 30),  // Was 5s, too short for cold start
```

---

### CONFLICT 10: Image URLs in Mobile App (LOW)

**Problem:** Listing images are stored as relative paths (`/uploads/listings/2026/01/abc.jpg`). The mobile app prepends `serverBaseUrl` to build full URLs. If the server URL changes, cached image URLs break.

**Evidence:** `listing.imageUrls(serverBaseUrl)` in multiple screens.

**Impact:** Minor — images reload when server URL changes. CachedNetworkImage handles this gracefully.

**No code change needed.** Just ensure the Render URL is set correctly.

---

## 3. THE PLAN

### Phase 1: Prepare Render Backend (30 minutes)

**Step 1.1 — Add Persistent Disk on Render**
```
Render Dashboard → Web Service → Disks → Add Disk
  Name: searchanycars-data
  Mount Path: /var/data
  Size: 1 GB
```

**Step 1.2 — Set Environment Variables on Render**
```
# Database & Storage
DATABASE_PATH=/var/data/searchanycars.db
UPLOADS_DIR=/var/data/uploads

# Security (generate unique values!)
JWT_ACCESS_SECRET=<generate: node -e "console.log(require('crypto').randomBytes(48).toString('hex'))">
JWT_REFRESH_SECRET=<generate: different random string>
ADMIN_DEFAULT_PASSWORD=<your-strong-password>
COOKIE_SECURE=true
NODE_ENV=production

# CORS (your Render URL)
CORS_ORIGINS=https://searchanycars-app.onrender.com

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=<your-email>
SMTP_PASS=<your-gmail-app-password>
COMPANY_EMAIL=<your-business-email>
FRONTEND_URL=https://searchanycars-app.onrender.com
```

**Step 1.3 — Fix CORS security bug**
```javascript
// server/middleware/security.js — line 19
// Change from:
callback(null, true)  // allows all
// To:
callback(new Error('CORS origin not allowed'), false)
```

**Step 1.4 — Deploy to Render**
```bash
git add -A && git commit -m "Configure for Render production deployment"
git push  # Render auto-deploys from main branch
```

**Step 1.5 — Verify backend is live**
```bash
curl https://searchanycars-app.onrender.com/api/health
# Expected: {"ok":true,"service":"searchanycars-api",...}
```

---

### Phase 2: Update Mobile App for Global Access (20 minutes)

**Step 2.1 — Set default server URL to Render**
```dart
// lib/providers/connectivity_provider.dart
static const String _defaultServerUrl = 'https://searchanycars-app.onrender.com';
```

**Step 2.2 — Smart URL scheme detection**
```dart
// Detect HTTPS for cloud hosts, HTTP for local
if (!normalized.startsWith('http')) {
  if (normalized.contains('.onrender.com') || ...) {
    normalized = 'https://$normalized';
  } else {
    normalized = 'http://$normalized';
  }
}
```

**Step 2.3 — Increase connect timeout for cold starts**
```dart
// lib/services/api/dio_client.dart
connectTimeout: const Duration(seconds: 30),
```

**Step 2.4 — Build release APK**
```bash
cd mobile-app-flutter
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

### Phase 3: Test End-to-End (15 minutes)

```
Test Matrix:
============

1. [Website on Desktop]
   Open https://searchanycars-app.onrender.com
   ✓ Homepage loads with listings
   ✓ Search works
   ✓ Register new account
   ✓ Login
   ✓ Add car to wishlist
   ✓ Book test drive → check email received

2. [Mobile App on Phone]
   Install APK
   ✓ App opens, auto-connects to Render
   ✓ Listings load
   ✓ Login with SAME account as website
   ✓ Wishlist shows SAME cars as website  ← SYNC VERIFIED
   ✓ Book test drive → check email received
   ✓ My Bookings shows booking

3. [Cross-Platform Sync]
   ✓ Save car on website → appears in app wishlist
   ✓ Save car on app → appears in website wishlist
   ✓ Book test drive on app → shows in website My Bookings
   ✓ Admin updates booking status → user sees update on both

4. [Offline/Recovery]
   ✓ Turn off WiFi on phone → app shows offline banner + cached data
   ✓ Turn WiFi back on → app reconnects, data refreshes
   ✓ Kill and reopen app → auto-connects, session restored
```

---

## 4. ARCHITECTURE AFTER DEPLOYMENT

```
                    ┌──────────────────────────────────┐
                    │     Render Cloud (Always On)      │
                    │                                    │
                    │  Express Server (:443 HTTPS)       │
                    │  ├── React Website (dist/)         │
                    │  ├── API Routes (/api/*)            │
                    │  └── Static Files (/uploads/*)      │
                    │                                    │
                    │  Persistent Disk (/var/data/)       │
                    │  ├── searchanycars.db (SQLite)      │
                    │  └── uploads/listings/** (Images)   │
                    │                                    │
                    │  URL: https://searchanycars-app     │
                    │        .onrender.com                │
                    └───────────────┬──────────────────┘
                                    │
                     ┌──────────────┴──────────────┐
                     │                             │
              ┌──────┴──────┐              ┌───────┴───────┐
              │   Browser   │              │  Flutter App  │
              │   (Anyone)  │              │  (Anyone)     │
              │             │              │               │
              │ Same URL    │              │ Hardcoded URL │
              │ HTTPS       │              │ HTTPS + Dio   │
              │ Cookies     │              │ CookieJar     │
              └─────────────┘              └───────────────┘
                     │                             │
                     └──────────┬──────────────────┘
                                │
                    Shared Backend = Shared Data
                    ✓ Same users
                    ✓ Same listings
                    ✓ Same wishlist (synced)
                    ✓ Same bookings (synced)
                    ✓ Same admin panel
```

---

## 5. ENVIRONMENT VARIABLES CHECKLIST

Copy this to Render Dashboard → Environment:

```bash
# === REQUIRED ===
DATABASE_PATH=/var/data/searchanycars.db
UPLOADS_DIR=/var/data/uploads
NODE_ENV=production
COOKIE_SECURE=true
JWT_ACCESS_SECRET=         # Generate: node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"
JWT_REFRESH_SECRET=        # Generate: different value
ADMIN_DEFAULT_PASSWORD=    # Your strong admin password

# === RECOMMENDED ===
CORS_ORIGINS=https://searchanycars-app.onrender.com
FRONTEND_URL=https://searchanycars-app.onrender.com

# === EMAIL (for booking confirmations & password reset) ===
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=                 # Your Gmail address
SMTP_PASS=                 # Gmail App Password (not regular password)
COMPANY_EMAIL=             # Business email shown in emails
COMPANY_NAME=SearchAnyCars

# === AUTO-SET BY RENDER (don't add manually) ===
# PORT                     # Render sets this automatically
# RENDER_EXTERNAL_URL      # Render sets this automatically
```

---

## 6. COST SUMMARY

| Item | Provider | Cost |
|------|----------|------|
| Web Service | Render Starter | $7/month (or free with cold starts) |
| Persistent Disk (1GB) | Render | $0.25/month |
| Domain (optional) | Namecheap/GoDaddy | ~$10/year |
| SSL Certificate | Render | Free (automatic) |
| Email (Gmail SMTP) | Google | Free (500 emails/day) |
| **Total (minimum)** | | **$0.25/month** (free tier + disk) |
| **Total (recommended)** | | **$7.25/month** (starter + disk) |

---

## 7. FUTURE IMPROVEMENTS

| Improvement | When | Why |
|-------------|------|-----|
| Custom domain (searchanycars.com) | After launch | Professional branding |
| Migrate SQLite → PostgreSQL | When data > 500MB | Better concurrency, backups |
| Move images to Cloudinary/S3 | When images > 1GB | CDN delivery, no disk limits |
| Add push notifications | After Play Store | Booking confirmations, price drops |
| Play Store listing | After testing | Global Android distribution |
| iOS build + App Store | After Android stable | iPhone users |
| CI/CD pipeline | After stable | Automated testing + deploy |
