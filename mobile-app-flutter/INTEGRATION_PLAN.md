# SearchAnyCars Mobile App - Backend Integration Plan

> **Version:** 1.0
> **Date:** 2026-03-27
> **Status:** Planning Phase - No Implementation
> **Author:** Architecture Review by Claude Opus 4.6

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Current State Analysis](#2-current-state-analysis)
3. [Architecture Overview](#3-architecture-overview)
4. [Network & Connectivity Architecture](#4-network--connectivity-architecture)
5. [API Integration Layer Design](#5-api-integration-layer-design)
6. [Authentication Strategy](#6-authentication-strategy)
7. [Data Flow Architecture](#7-data-flow-architecture)
8. [Offline-First & Standalone Design](#8-offline-first--standalone-design)
9. [Image Loading Strategy](#9-image-loading-strategy)
10. [State Management Redesign](#10-state-management-redesign)
11. [Conflict Analysis & Mitigations](#11-conflict-analysis--mitigations)
12. [Screen-by-Screen Integration Map](#12-screen-by-screen-integration-map)
13. [Migration Phases](#13-migration-phases)
14. [File Structure Changes](#14-file-structure-changes)
15. [Testing Strategy](#15-testing-strategy)
16. [Risk Register](#16-risk-register)

---

## 1. Executive Summary

The SearchAnyCars Flutter app currently runs as a **prototype with hardcoded mock data**. This plan outlines how to integrate it with the **existing Express + SQLite backend** running on a local network, while maintaining a **standalone, loosely-coupled architecture** so the app functions gracefully even without backend connectivity.

### Key Principles

```
+------------------------------------------------------------------+
|                      DESIGN PRINCIPLES                           |
+------------------------------------------------------------------+
|                                                                  |
|  1. STANDALONE FIRST                                             |
|     App must launch and be usable without network                |
|                                                                  |
|  2. LOOSELY COUPLED                                              |
|     Backend is a data source, not a dependency                   |
|     App works with mock data OR live data                        |
|                                                                  |
|  3. NETWORK AWARE                                                |
|     Detect connectivity, switch data sources seamlessly          |
|                                                                  |
|  4. SINGLE BACKEND, MULTIPLE CLIENTS                             |
|     Same Express API serves website AND mobile app               |
|     No backend modifications required                            |
|                                                                  |
|  5. GRACEFUL DEGRADATION                                         |
|     No crashes on timeout/error — show cached or fallback data   |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 2. Current State Analysis

### 2.1 What We Have Now (Mobile App - Prototype)

```
+----------------------------------------------+
|          CURRENT FLUTTER APP                 |
+----------------------------------------------+
|                                              |
|  lib/models/mock_data.dart                   |
|    - 8 hardcoded cars                        |
|    - 8 hardcoded brands                      |
|    - 1 hardcoded user (Karthi M)             |
|    - Static filter chips                     |
|    - Static trust items                      |
|                                              |
|  lib/providers/app_provider.dart             |
|    - In-memory wishlist [1, 3]               |
|    - Client-side search filtering            |
|    - No persistence across sessions          |
|                                              |
|  NO network calls                            |
|  NO authentication                           |
|  NO image URLs (using brand initials)        |
|  NO real-time updates                        |
|                                              |
+----------------------------------------------+
```

### 2.2 What We Have Now (Backend Server)

```
+----------------------------------------------+
|         EXPRESS BACKEND (Port 4000)          |
+----------------------------------------------+
|                                              |
|  Database: SQLite (better-sqlite3)           |
|    - listings: 150+ columns per car          |
|    - categories: 8 vehicle types             |
|    - filter_definitions: 13 filter types     |
|    - users: JWT auth with refresh tokens     |
|    - sessions: token rotation                |
|    - site_config: 14 configurable sections   |
|                                              |
|  API Endpoints:                              |
|    GET  /api/listings          (public)      |
|    GET  /api/listings/:id      (public)      |
|    GET  /api/categories        (public)      |
|    GET  /api/filter-definitions (public)     |
|    GET  /api/site-config       (public)      |
|    POST /api/auth/login        (public)      |
|    POST /api/auth/register     (public)      |
|    POST /api/auth/refresh      (public)      |
|    GET  /api/auth/me           (auth)        |
|    POST /api/auth/logout       (auth)        |
|    GET  /api/events            (SSE)         |
|                                              |
|  Auth: JWT in HTTP-only cookies              |
|  CORS: Currently allows all in dev           |
|  Images: /uploads/listings/YYYY/MM/          |
|  Rate Limit: 200 req/15min                   |
|                                              |
+----------------------------------------------+
```

### 2.3 Data Model Gap Analysis

```
+---------------------------+----------------------------+------------------+
| PROTOTYPE (mock_data)     | BACKEND (listings table)   | ACTION NEEDED    |
+---------------------------+----------------------------+------------------+
| car.id (int)              | listing.id (int)           | Direct map       |
| car.name (string)         | listing.title (string)     | Rename field     |
| car.brand (string)        | listing.brand (string)     | Direct map       |
| car.year (int)            | listing.model_year (int)   | Rename field     |
| car.price ("32.5L")       | listing_price_inr (number) | Parse/format     |
| car.km ("18,200")         | total_km_driven (number)   | Parse/format     |
| car.fuel (string)         | fuel_type (string)         | Direct map       |
| car.transmission (string) | transmission_type (string) | Rename field     |
| car.owner ("1st")         | ownership_type ("First")   | Map values       |
| car.city (string)         | location_city (string)     | Direct map       |
| car.rating (double)       | inspection_score (double)  | Rename field     |
| car.color (hex)           | exterior_color (string)    | May differ       |
| car.badge (string)        | promotion_tier (string)    | Map logic        |
| car.emi (string)          | -- (calculated)            | Client-side calc |
| car.certified (bool)      | platform_certified (int)   | Map 0/1 -> bool  |
| car.images (NONE)         | images (string[])          | NEW - add        |
| -- (missing)              | 100+ more fields           | NEW - add        |
+---------------------------+----------------------------+------------------+
```

---

## 3. Architecture Overview

### 3.1 Target Architecture Diagram

```
+------------------------------------------------------------------+
|                        MOBILE DEVICE                             |
|                                                                  |
|  +------------------------------------------------------------+ |
|  |                   FLUTTER APP                               | |
|  |                                                              | |
|  |  +------------------+    +--------------------+             | |
|  |  |   UI LAYER       |    |   STATE LAYER      |             | |
|  |  |                  |    |   (Riverpod)        |             | |
|  |  |  Screens         |<-->|                     |             | |
|  |  |  Widgets         |    |  CarNotifier        |             | |
|  |  |  Animations      |    |  AuthNotifier       |             | |
|  |  |                  |    |  WishlistNotifier    |             | |
|  |  +------------------+    |  ConfigNotifier      |             | |
|  |                          +----------+-----------+             | |
|  |                                     |                         | |
|  |                          +----------v-----------+             | |
|  |                          |  REPOSITORY LAYER    |             | |
|  |                          |                      |             | |
|  |                          |  CarRepository       |             | |
|  |                          |  AuthRepository      |             | |
|  |                          |  ConfigRepository    |             | |
|  |                          +----+------------+----+             | |
|  |                               |            |                  | |
|  |                    +----------v--+  +------v---------+       | |
|  |                    | API SERVICE |  | LOCAL CACHE    |       | |
|  |                    | (Dio)       |  | (Hive/SharedP) |       | |
|  |                    +------+------+  +----------------+       | |
|  |                           |                                   | |
|  +------------------------------------------------------------+ |
|                              |                                   |
+------------------------------+-----------------------------------+
                               |
                        [ LOCAL NETWORK ]
                               |
+------------------------------v-----------------------------------+
|                     SERVER MACHINE                                |
|                                                                  |
|  +------------------------------------------------------------+ |
|  |              EXPRESS SERVER (Port 4000)                      | |
|  |                                                              | |
|  |  /api/listings      /api/auth/*      /api/site-config       | |
|  |  /api/categories    /api/events      /uploads/*             | |
|  |                                                              | |
|  |  +------------------+    +--------------------+             | |
|  |  |   SQLite DB      |    |   /uploads/        |             | |
|  |  |   searchanycars  |    |   listings/        |             | |
|  |  |   .db            |    |   YYYY/MM/         |             | |
|  |  +------------------+    +--------------------+             | |
|  +------------------------------------------------------------+ |
|                                                                  |
|  +------------------------------------------------------------+ |
|  |              VITE DEV SERVER (Port 5173)                    | |
|  |              (Website - separate client)                     | |
|  +------------------------------------------------------------+ |
+------------------------------------------------------------------+
```

### 3.2 Layer Separation

```
+------------------------------------------------------------------+
|                    DEPENDENCY DIRECTION                           |
|                    (Clean Architecture)                           |
+------------------------------------------------------------------+
|                                                                  |
|     UI (Screens, Widgets)                                        |
|           |                                                      |
|           | depends on                                           |
|           v                                                      |
|     STATE (Riverpod Providers/Notifiers)                         |
|           |                                                      |
|           | depends on                                           |
|           v                                                      |
|     REPOSITORY (Abstract interface)                              |
|           |                                                      |
|           | implements                                           |
|           v                                                      |
|     +-----+-----+                                               |
|     |           |                                                |
|     v           v                                                |
|   API        LOCAL                                               |
|   SERVICE    CACHE                                               |
|   (Dio)      (Hive)                                              |
|                                                                  |
|  UI never knows WHERE data comes from.                           |
|  Repository decides: network? cache? mock?                       |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 4. Network & Connectivity Architecture

### 4.1 Connection Discovery Flow

```
+------------------------------------------------------------------+
|                  APP STARTUP FLOW                                 |
+------------------------------------------------------------------+
|                                                                  |
|   App Launches                                                   |
|       |                                                          |
|       v                                                          |
|   Load saved server URL from local storage                       |
|       |                                                          |
|       +--- URL exists? ---+--- No ---> Show Settings Screen     |
|       |                   |            (Enter server IP:port)    |
|       | Yes               |            OR use mock data          |
|       v                   |                                      |
|   Ping /api/health        |                                      |
|       |                   |                                      |
|       +--- Success? ------+--- No ---> Use cached/mock data     |
|       |                   |            Show "Offline" badge      |
|       | Yes               |                                      |
|       v                   |                                      |
|   Connected!              |                                      |
|   Fetch fresh data        |                                      |
|   Update cache            |                                      |
|       |                   |                                      |
|       v                   v                                      |
|   NORMAL MODE         OFFLINE MODE                               |
|   (live data)         (cached data)                              |
|                                                                  |
+------------------------------------------------------------------+
```

### 4.2 Server URL Configuration

The app needs a way for users to specify the backend server address since it runs on a local network with potentially different IPs.

```
+------------------------------------------------------------------+
|                  SERVER CONFIGURATION                             |
+------------------------------------------------------------------+
|                                                                  |
|   Settings Screen:                                               |
|   +----------------------------------------------------------+  |
|   |  Server Address:  [ http://192.168.1.100:4000 ]          |  |
|   |                                                          |  |
|   |  [Auto-Discover]    [Test Connection]    [Save]          |  |
|   |                                                          |  |
|   |  Status: ● Connected                                     |  |
|   +----------------------------------------------------------+  |
|                                                                  |
|   Storage: SharedPreferences                                     |
|   Key: 'server_base_url'                                         |
|   Default: '' (empty = offline/mock mode)                        |
|                                                                  |
|   URL Format: http://{IP}:{PORT}                                 |
|   Example: http://192.168.1.100:4000                             |
|                                                                  |
|   Health Check: GET {base_url}/api/health                        |
|   Expected:    { "ok": true, ... }                               |
|                                                                  |
+------------------------------------------------------------------+
```

### 4.3 Connectivity State Machine

```
+------------------------------------------------------------------+
|                CONNECTIVITY STATES                                |
+------------------------------------------------------------------+
|                                                                  |
|                    +------------+                                |
|           +------->|  UNKNOWN   |<--------+                     |
|           |        +-----+------+         |                     |
|           |              |                |                     |
|           |         check health          |                     |
|           |              |                |                     |
|           |    +---------+---------+      |                     |
|           |    |                   |      |                     |
|           |    v                   v      |                     |
|           | +--------+      +----------+ |                     |
|           | |CONNECTED|     |DISCONNECTED| |                     |
|           | |  (live) |     | (offline)  | |                     |
|           | +----+---+      +-----+----+ |                     |
|           |      |                |      |                     |
|           |      |  API error/    |      |                     |
|           |      |  timeout       | periodic                   |
|           |      +-------+--------+ retry                      |
|           |              |          (30s)                       |
|           |              v            |                         |
|           |        +-----------+      |                         |
|           +--------|RECONNECTING|-----+                         |
|                    +-----------+                                |
|                                                                  |
|   CONNECTED:      Use live API, cache responses                  |
|   DISCONNECTED:   Use cached data, show offline badge            |
|   RECONNECTING:   Retry health check every 30 seconds            |
|   UNKNOWN:        Initial state on app launch                    |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 5. API Integration Layer Design

### 5.1 Dio HTTP Client Configuration

```
+------------------------------------------------------------------+
|               DIO CLIENT SETUP                                   |
+------------------------------------------------------------------+
|                                                                  |
|   Base Configuration:                                            |
|   - baseUrl: from saved server URL                               |
|   - connectTimeout: 5 seconds                                    |
|   - receiveTimeout: 10 seconds                                   |
|   - Content-Type: application/json                               |
|                                                                  |
|   Interceptors Chain:                                            |
|   +----------------------------------------------------------+  |
|   |  1. AuthInterceptor                                      |  |
|   |     - Attach access token to headers                     |  |
|   |     - On 401: attempt token refresh, retry request       |  |
|   |     - On refresh fail: clear auth state                  |  |
|   +----------------------------------------------------------+  |
|   |  2. ConnectivityInterceptor                              |  |
|   |     - Check network before request                       |  |
|   |     - On timeout: set state to DISCONNECTED              |  |
|   |     - On success: set state to CONNECTED                 |  |
|   +----------------------------------------------------------+  |
|   |  3. CacheInterceptor                                     |  |
|   |     - Cache GET responses in Hive                        |  |
|   |     - On error: return cached response if available      |  |
|   |     - Cache key: URL + query params hash                 |  |
|   +----------------------------------------------------------+  |
|   |  4. LogInterceptor (debug only)                          |  |
|   |     - Log request/response for debugging                 |  |
|   +----------------------------------------------------------+  |
|                                                                  |
+------------------------------------------------------------------+
```

### 5.2 Authentication Token Strategy

**CRITICAL CONFLICT**: The backend uses **HTTP-only cookies** for auth tokens. Mobile apps **cannot access HTTP-only cookies** reliably with Dio. This is the biggest integration challenge.

```
+------------------------------------------------------------------+
|            AUTH TOKEN CONFLICT & SOLUTION                         |
+------------------------------------------------------------------+
|                                                                  |
|   PROBLEM:                                                       |
|   +----------------------------------------------------------+  |
|   |  Backend sets tokens as HTTP-only cookies:               |  |
|   |    Set-Cookie: access_token=xxx; HttpOnly; Path=/        |  |
|   |    Set-Cookie: refresh_token=xxx; HttpOnly; Path=/       |  |
|   |                                                          |  |
|   |  Flutter/Dio CAN handle cookies via cookie jar,          |  |
|   |  but HTTP-only cookies have cross-origin issues on       |  |
|   |  mobile and require careful cookie management.           |  |
|   +----------------------------------------------------------+  |
|                                                                  |
|   SOLUTION: Use Dio Cookie Manager                               |
|   +----------------------------------------------------------+  |
|   |  1. Add: dio_cookie_manager + cookie_jar packages        |  |
|   |                                                          |  |
|   |  2. Dio automatically stores Set-Cookie headers          |  |
|   |     and sends them back on subsequent requests           |  |
|   |                                                          |  |
|   |  3. PersistCookieJar saves cookies to disk               |  |
|   |     (survives app restart)                               |  |
|   |                                                          |  |
|   |  4. Flow:                                                |  |
|   |     POST /auth/login                                     |  |
|   |       -> Response has Set-Cookie headers                 |  |
|   |       -> CookieJar stores them automatically             |  |
|   |     GET /auth/me                                         |  |
|   |       -> CookieJar attaches cookies automatically        |  |
|   |       -> Server validates, returns user                  |  |
|   +----------------------------------------------------------+  |
|                                                                  |
|   ALTERNATIVE (if cookies don't work):                           |
|   +----------------------------------------------------------+  |
|   |  Add a mobile-specific auth endpoint to backend:         |  |
|   |    POST /api/auth/mobile-login                           |  |
|   |    Response: { accessToken, refreshToken, user }         |  |
|   |    (returns tokens in body, not cookies)                 |  |
|   |                                                          |  |
|   |  Store tokens in secure storage (flutter_secure_storage) |  |
|   |  Attach as Authorization: Bearer {token} header          |  |
|   |                                                          |  |
|   |  NOTE: This requires a backend change.                   |  |
|   |  Try cookie approach FIRST.                              |  |
|   +----------------------------------------------------------+  |
|                                                                  |
+------------------------------------------------------------------+
```

### 5.3 API Service Interfaces

```
+------------------------------------------------------------------+
|              SERVICE LAYER DESIGN                                |
+------------------------------------------------------------------+
|                                                                  |
|   CarService (abstract)                                          |
|   +----------------------------------------------------------+  |
|   |  Future<List<Listing>> getListings({                     |  |
|   |    String? search,                                       |  |
|   |    String? brand,                                        |  |
|   |    String? fuelType,                                     |  |
|   |    String? transmissionType,                             |  |
|   |    String? bodyStyle,                                    |  |
|   |    double? priceMin,                                     |  |
|   |    double? priceMax,                                     |  |
|   |    String? sortBy,                                       |  |
|   |  });                                                     |  |
|   |                                                          |  |
|   |  Future<Listing> getListingById(int id);                 |  |
|   |  Future<List<Category>> getCategories();                 |  |
|   |  Future<List<FilterDefinition>> getFilterDefinitions();  |  |
|   +----------------------------------------------------------+  |
|                                                                  |
|   Implementations:                                               |
|   +---------------------------+  +---------------------------+  |
|   | ApiCarService             |  | MockCarService            |  |
|   | (calls /api/listings)     |  | (returns mock_data.dart)  |  |
|   +---------------------------+  +---------------------------+  |
|                                                                  |
|   AuthService (abstract)                                         |
|   +----------------------------------------------------------+  |
|   |  Future<User> login(String email, String password);      |  |
|   |  Future<User> register(String email, String password);   |  |
|   |  Future<User?> getCurrentUser();                         |  |
|   |  Future<void> logout();                                  |  |
|   |  Future<User> refreshToken();                            |  |
|   +----------------------------------------------------------+  |
|                                                                  |
|   ConfigService (abstract)                                       |
|   +----------------------------------------------------------+  |
|   |  Future<SiteConfig> getSiteConfig();                     |  |
|   |  Future<dynamic> getConfigByKey(String key);             |  |
|   +----------------------------------------------------------+  |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 6. Authentication Strategy

### 6.1 Auth Flow Diagram

```
+------------------------------------------------------------------+
|                  AUTHENTICATION FLOW                              |
+------------------------------------------------------------------+
|                                                                  |
|   APP START                                                      |
|       |                                                          |
|       v                                                          |
|   Check for saved session (cookie jar / secure storage)          |
|       |                                                          |
|       +--- Has session? ---+--- No ---> Guest Mode              |
|       |                    |            (browse only)            |
|       | Yes                |                                     |
|       v                    |                                     |
|   GET /api/auth/me         |                                     |
|       |                    |                                     |
|       +--- 200 OK? -------+--- 401 ---> Try refresh token      |
|       |                    |                    |                |
|       | Yes                |              POST /api/auth/refresh |
|       v                    |                    |                |
|   Authenticated!           |              +-----+-----+         |
|   Load user data           |              |           |         |
|       |                    |           200 OK      401          |
|       v                    |              |        Guest Mode   |
|   HOME SCREEN              |         Authenticated!             |
|                            |              |                     |
|                            +--------------+                     |
|                                                                  |
+------------------------------------------------------------------+
|                                                                  |
|   GUEST MODE CAPABILITIES:                                       |
|   - Browse all car listings                                      |
|   - Search and filter                                            |
|   - View car details                                             |
|   - Local wishlist (device only)                                 |
|                                                                  |
|   AUTHENTICATED CAPABILITIES:                                    |
|   - All guest features                                           |
|   - Synced wishlist                                              |
|   - Book test drives                                             |
|   - Contact dealers                                              |
|   - Profile management                                           |
|                                                                  |
+------------------------------------------------------------------+
```

### 6.2 Auth is OPTIONAL

The app must work fully in guest mode. Auth adds value but is not a gate.

```
+------------------------------------------------------------------+
|              GUEST vs AUTHENTICATED                              |
+------------------------------------------------------------------+
|                                                                  |
|   Feature           | Guest        | Authenticated              |
|   ------------------+--------------+---------------------------  |
|   Browse listings   | YES          | YES                        |
|   Search & filter   | YES          | YES                        |
|   View car details  | YES          | YES                        |
|   Wishlist          | LOCAL only   | Synced to server           |
|   Compare cars      | YES          | YES                        |
|   Book test drive   | NO (prompt)  | YES                        |
|   Profile           | Login prompt | Full profile               |
|   Contact dealer    | NO (prompt)  | YES (phone/chat)           |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 7. Data Flow Architecture

### 7.1 Repository Pattern with Fallback

```
+------------------------------------------------------------------+
|            REPOSITORY DECISION TREE                              |
+------------------------------------------------------------------+
|                                                                  |
|   Provider requests data                                         |
|       |                                                          |
|       v                                                          |
|   Repository.getListings()                                       |
|       |                                                          |
|       +--- Is connected? ---+--- No ---> Read from Hive cache   |
|       |                     |                    |               |
|       | Yes                 |              +-----+-----+        |
|       v                     |              |           |        |
|   Call API Service          |          Has cache?   No cache    |
|       |                     |              |           |        |
|       +--- Success? --------+         Return       Return       |
|       |                     |         cached       mock data    |
|       | Yes                 | No      data                      |
|       v                     v                                    |
|   Update Hive cache    Return cached                             |
|   Return fresh data    (or mock if                               |
|                        no cache)                                 |
|                                                                  |
+------------------------------------------------------------------+
```

### 7.2 Data Transformation Pipeline

```
+------------------------------------------------------------------+
|          BACKEND RESPONSE -> FLUTTER MODEL                       |
+------------------------------------------------------------------+
|                                                                  |
|   Backend JSON (listing):                                        |
|   {                                                              |
|     "id": 1,                                                     |
|     "title": "2022 Hyundai Creta SX(O)",                        |
|     "brand": "Hyundai",                                          |
|     "model": "Creta",                                            |
|     "model_year": 2022,                                          |
|     "listing_price_inr": 1450000,                                |
|     "total_km_driven": 18200,                                    |
|     "fuel_type": "Petrol",                                       |
|     "transmission_type": "Automatic",                            |
|     "ownership_type": "First",                                   |
|     "location_city": "Mumbai",                                   |
|     "inspection_score": 4.8,                                     |
|     "exterior_color": "Silver",                                  |
|     "images": ["/uploads/listings/2026/01/abc.jpg"],             |
|     "listing_status": "Active",                                  |
|     "featured_listing": 1,                                       |
|     ...150+ more fields                                          |
|   }                                                              |
|                                                                  |
|           | Listing.fromJson(json)                                |
|           v                                                      |
|                                                                  |
|   Flutter Listing Model:                                         |
|   Listing(                                                       |
|     id: 1,                                                       |
|     title: "2022 Hyundai Creta SX(O)",                           |
|     brand: "Hyundai",                                            |
|     model: "Creta",                                              |
|     modelYear: 2022,                                             |
|     priceInr: 1450000,                                           |
|     priceFormatted: "14.5L",    // <-- computed                  |
|     emiFormatted: "21,500/mo",  // <-- computed client-side      |
|     totalKmDriven: 18200,                                        |
|     kmFormatted: "18,200",      // <-- computed                  |
|     fuelType: "Petrol",                                          |
|     transmissionType: "Automatic",                               |
|     ownershipType: "First",                                      |
|     ownerDisplay: "1st",        // <-- mapped                    |
|     locationCity: "Mumbai",                                      |
|     inspectionScore: 4.8,                                        |
|     images: ["http://192.168.1.100:4000/uploads/..."],           |
|     imageUrls: [...],           // <-- full URLs built           |
|     isFeatured: true,           // <-- from int                  |
|     ...                                                          |
|   )                                                              |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 8. Offline-First & Standalone Design

### 8.1 Cache Architecture

```
+------------------------------------------------------------------+
|                CACHING STRATEGY                                  |
+------------------------------------------------------------------+
|                                                                  |
|   +---------------------------+                                  |
|   |     HIVE BOXES            |                                  |
|   +---------------------------+                                  |
|   |                           |                                  |
|   |  Box: 'listings'          |  All car listings cached         |
|   |    Key: listing ID        |  TTL: 1 hour                    |
|   |    Value: JSON map        |                                  |
|   |                           |                                  |
|   |  Box: 'categories'        |  Vehicle categories              |
|   |    Key: 'all'             |  TTL: 24 hours                  |
|   |    Value: JSON list       |                                  |
|   |                           |                                  |
|   |  Box: 'site_config'       |  Site configuration              |
|   |    Key: config key        |  TTL: 6 hours                   |
|   |    Value: JSON            |                                  |
|   |                           |                                  |
|   |  Box: 'wishlist'          |  Local wishlist IDs              |
|   |    Key: 'ids'             |  No TTL (permanent)             |
|   |    Value: List<int>       |                                  |
|   |                           |                                  |
|   |  Box: 'user'              |  Cached user profile             |
|   |    Key: 'current'         |  TTL: until logout              |
|   |    Value: JSON map        |                                  |
|   |                           |                                  |
|   |  Box: 'settings'          |  App settings                    |
|   |    Key: 'server_url'      |  No TTL                         |
|   |    Value: string          |                                  |
|   |                           |                                  |
|   +---------------------------+                                  |
|                                                                  |
|   SharedPreferences:                                             |
|   - server_base_url                                              |
|   - last_sync_timestamp                                          |
|   - onboarding_completed                                         |
|   - app_theme_preference                                         |
|                                                                  |
+------------------------------------------------------------------+
```

### 8.2 Offline Mode UI Indicators

```
+------------------------------------------------------------------+
|              OFFLINE MODE BEHAVIOR                               |
+------------------------------------------------------------------+
|                                                                  |
|   When DISCONNECTED:                                             |
|                                                                  |
|   +----------------------------------------------------------+  |
|   |  ▼ Home Screen Header                                    |  |
|   |  +------------------------------------------------------+|  |
|   |  | [!] Offline Mode - Showing cached data     [Retry]   ||  |
|   |  +------------------------------------------------------+|  |
|   |                                                          |  |
|   |  All screens show cached data normally                   |  |
|   |  Search works on cached listings only                    |  |
|   |  Wishlist works locally                                  |  |
|   |  "Book Test Drive" shows "Connect to network" prompt     |  |
|   |  Pull-to-refresh shows "No connection" snackbar          |  |
|   +----------------------------------------------------------+  |
|                                                                  |
|   When RECONNECTED:                                              |
|   - Silent background refresh                                    |
|   - Sync local wishlist changes                                  |
|   - Show "Back online" snackbar briefly                          |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 9. Image Loading Strategy

### 9.1 Image URL Construction

```
+------------------------------------------------------------------+
|              IMAGE URL HANDLING                                   |
+------------------------------------------------------------------+
|                                                                  |
|   Backend stores: "/uploads/listings/2026/03/uuid-name.jpg"      |
|   (relative path)                                                |
|                                                                  |
|   App must build full URL:                                       |
|   "{server_base_url}/uploads/listings/2026/03/uuid-name.jpg"     |
|   = "http://192.168.1.100:4000/uploads/listings/..."             |
|                                                                  |
|   Image Loading Stack:                                           |
|   +----------------------------------------------------------+  |
|   |  cached_network_image                                    |  |
|   |    |                                                     |  |
|   |    +-- Has disk cache? --> Show cached image             |  |
|   |    |                                                     |  |
|   |    +-- No cache? --> Download from server                |  |
|   |    |                    |                                |  |
|   |    |               +----+----+                           |  |
|   |    |               |         |                           |  |
|   |    |            Success    Error                         |  |
|   |    |               |         |                           |  |
|   |    |          Cache &    Show placeholder                |  |
|   |    |          display    (brand initial on               |  |
|   |    |                      gradient - current style)      |  |
|   +----------------------------------------------------------+  |
|                                                                  |
|   Placeholder Widget (fallback when no image):                   |
|   +----------------------------------------------------------+  |
|   |  Container(                                              |  |
|   |    gradient: car color gradient,                         |  |
|   |    child: Text(brand[0], style: large semi-transparent), |  |
|   |  )                                                       |  |
|   |  // Same as current prototype - seamless fallback        |  |
|   +----------------------------------------------------------+  |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 10. State Management Redesign

### 10.1 Provider Architecture

```
+------------------------------------------------------------------+
|           RIVERPOD PROVIDER TREE                                 |
+------------------------------------------------------------------+
|                                                                  |
|   INFRASTRUCTURE PROVIDERS                                       |
|   +----------------------------------------------------------+  |
|   |  serverUrlProvider        -> String (from SharedPrefs)   |  |
|   |  dioProvider              -> Dio (configured with URL)   |  |
|   |  connectivityProvider     -> ConnectivityState            |  |
|   +----------------------------------------------------------+  |
|                                                                  |
|   SERVICE PROVIDERS                                              |
|   +----------------------------------------------------------+  |
|   |  carServiceProvider       -> CarService (API or Mock)    |  |
|   |  authServiceProvider      -> AuthService                 |  |
|   |  configServiceProvider    -> ConfigService               |  |
|   +----------------------------------------------------------+  |
|                                                                  |
|   REPOSITORY PROVIDERS                                           |
|   +----------------------------------------------------------+  |
|   |  carRepositoryProvider    -> CarRepository               |  |
|   |  authRepositoryProvider   -> AuthRepository              |  |
|   |  configRepositoryProvider -> ConfigRepository            |  |
|   +----------------------------------------------------------+  |
|                                                                  |
|   STATE PROVIDERS (what UI consumes)                             |
|   +----------------------------------------------------------+  |
|   |  listingsProvider         -> AsyncValue<List<Listing>>   |  |
|   |  featuredListingsProvider -> AsyncValue<List<Listing>>   |  |
|   |  listingDetailProvider(id)-> AsyncValue<Listing>         |  |
|   |  searchResultsProvider    -> AsyncValue<List<Listing>>   |  |
|   |  categoriesProvider       -> AsyncValue<List<Category>>  |  |
|   |  filtersProvider          -> AsyncValue<List<Filter>>    |  |
|   |  wishlistProvider         -> List<int>                   |  |
|   |  authStateProvider        -> AuthState (user or guest)   |  |
|   |  siteConfigProvider       -> AsyncValue<SiteConfig>      |  |
|   |  searchQueryProvider      -> SearchState                 |  |
|   |  compareCarsProvider      -> List<Listing>               |  |
|   +----------------------------------------------------------+  |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 11. Conflict Analysis & Mitigations

### 11.1 Known Conflicts

```
+====================================================================+
|  #  | CONFLICT                    | SEVERITY | MITIGATION          |
+====================================================================+
|     |                             |          |                     |
|  1  | HTTP-only cookies vs        | HIGH     | Use dio_cookie_     |
|     | mobile HTTP client          |          | manager with        |
|     |                             |          | PersistCookieJar.   |
|     |                             |          | If fails: add       |
|     |                             |          | bearer token        |
|     |                             |          | endpoint to backend |
+-----+-----------------------------+----------+---------------------+
|  2  | Backend CORS blocks         | HIGH     | Backend already     |
|     | mobile app requests         |          | allows all in dev.  |
|     |                             |          | For prod: add       |
|     |                             |          | mobile origin or    |
|     |                             |          | use wildcard for    |
|     |                             |          | local network.      |
+-----+-----------------------------+----------+---------------------+
|  3  | Image URLs are relative     | MEDIUM   | Build full URLs by  |
|     | paths, not absolute         |          | prepending server   |
|     |                             |          | base URL in the     |
|     |                             |          | model fromJson().   |
+-----+-----------------------------+----------+---------------------+
|  4  | Backend listing model has   | MEDIUM   | Flutter model only  |
|     | 150+ fields, prototype      |          | maps fields it      |
|     | model has ~15               |          | needs. Use          |
|     |                             |          | json[key] with      |
|     |                             |          | null safety.        |
+-----+-----------------------------+----------+---------------------+
|  5  | Price in backend is raw     | LOW      | Client-side         |
|     | INR number (1450000),       |          | formatting:         |
|     | prototype uses "14.5L"      |          | formatINR() and     |
|     | string                      |          | calculateEMI()      |
+-----+-----------------------------+----------+---------------------+
|  6  | Ownership values differ:    | LOW      | Map in fromJson:    |
|     | "First" vs "1st"            |          | "First" -> "1st"    |
|     |                             |          | "Second" -> "2nd"   |
+-----+-----------------------------+----------+---------------------+
|  7  | Backend has no "badge"      | LOW      | Derive badge from   |
|     | field matching prototype    |          | listing properties: |
|     | ("Premium","Like New")      |          | featured_listing,   |
|     |                             |          | is_splus, km,       |
|     |                             |          | condition_rating    |
+-----+-----------------------------+----------+---------------------+
|  8  | Wishlist in prototype is    | MEDIUM   | Keep local-first    |
|     | in-memory, backend has no   |          | wishlist in Hive.   |
|     | wishlist API (website uses  |          | No backend sync     |
|     | localStorage)               |          | needed (matches     |
|     |                             |          | website behavior).  |
+-----+-----------------------------+----------+---------------------+
|  9  | SSE for real-time config    | LOW      | Skip SSE for v1.    |
|     | updates may not work well   |          | Poll config on app  |
|     | on mobile (battery, bg)     |          | resume instead.     |
+-----+-----------------------------+----------+---------------------+
| 10  | Rate limiting (200 req/     | MEDIUM   | Implement request   |
|     | 15min) could be hit by      |          | debouncing and      |
|     | aggressive search typing    |          | caching. Debounce   |
|     |                             |          | search to 500ms.    |
+-----+-----------------------------+----------+---------------------+
| 11  | Backend SameSite=lax        | MEDIUM   | For local network   |
|     | cookies may not work        |          | HTTP, cookies       |
|     | cross-origin on mobile      |          | should work since   |
|     |                             |          | SameSite=lax        |
|     |                             |          | allows top-level    |
|     |                             |          | navigations.        |
|     |                             |          | Test & fallback     |
|     |                             |          | to bearer tokens.   |
+-----+-----------------------------+----------+---------------------+
| 12  | No pagination in backend    | LOW      | Acceptable for      |
|     | (returns all listings)      |          | local deployment    |
|     |                             |          | with small dataset. |
|     |                             |          | Cache all results.  |
+-----+-----------------------------+----------+---------------------+
| 13  | Server IP changes if        | MEDIUM   | Settings screen     |
|     | router reassigns DHCP       |          | to update URL.      |
|     |                             |          | Consider mDNS or    |
|     |                             |          | static IP.          |
+-----+-----------------------------+----------+---------------------+
| 14  | Mixed content: mobile on    | LOW      | Local network is    |
|     | HTTPS network accessing     |          | HTTP only. Android  |
|     | HTTP backend                |          | needs              |
|     |                             |          | usesCleartextTraffic|
|     |                             |          | =true in manifest.  |
+-----+-----------------------------+----------+---------------------+
```

### 11.2 Android Cleartext Traffic Configuration

```
+------------------------------------------------------------------+
|   REQUIRED: Android Network Security Config                      |
+------------------------------------------------------------------+
|                                                                  |
|   android/app/src/main/AndroidManifest.xml:                      |
|     <application                                                 |
|       android:usesCleartextTraffic="true"                        |
|       ...>                                                       |
|                                                                  |
|   This is REQUIRED for HTTP connections on local network.        |
|   Without it, Android blocks all non-HTTPS requests.             |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 12. Screen-by-Screen Integration Map

```
+====================================================================+
| SCREEN          | CURRENT DATA        | INTEGRATION               |
+====================================================================+
|                 |                     |                             |
| Splash          | Static animation    | No change needed.          |
|                 |                     | Add: check connectivity    |
|                 |                     | during animation.          |
+-----------------+---------------------+-----------------------------+
| Onboarding      | Static slides       | No change needed.          |
|                 |                     | One-time screen.           |
+-----------------+---------------------+-----------------------------+
| Home            | MockData.cars       | GET /api/listings          |
|                 | MockData.brands     |   ?featured_listing=1      |
|                 |                     | GET /api/listings          |
|                 |                     |   ?sortBy=latest           |
|                 |                     | GET /api/site-config       |
|                 |                     |   (hero, trust_bar)        |
|                 |                     | Brands: derived from       |
|                 |                     |   listings or site_config  |
+-----------------+---------------------+-----------------------------+
| Search          | MockData.cars       | GET /api/listings          |
|                 | Client filter       |   ?search=X                |
|                 |                     |   &brand=X                 |
|                 |                     |   &fuel_type=X             |
|                 |                     |   &body_style=X            |
|                 |                     |   &sortBy=X                |
|                 |                     | GET /api/categories        |
|                 |                     | GET /api/filter-definitions|
+-----------------+---------------------+-----------------------------+
| Car Detail      | MockData.cars[id]   | GET /api/listings/:id      |
|                 |                     | Full listing object        |
|                 |                     | Image gallery from         |
|                 |                     |   listing.images[]         |
|                 |                     | Inspection from            |
|                 |                     |   inspection_score +       |
|                 |                     |   condition fields         |
+-----------------+---------------------+-----------------------------+
| Wishlist        | In-memory [1,3]     | Local Hive storage         |
|                 |                     | Load listings by IDs       |
|                 |                     |   from cache or API        |
+-----------------+---------------------+-----------------------------+
| Compare         | Empty state         | Uses locally selected      |
|                 |                     | cars. No API needed.       |
|                 |                     | Data from cached listings. |
+-----------------+---------------------+-----------------------------+
| Profile         | MockData.user       | GET /api/auth/me           |
|                 |                     | If guest: show login       |
|                 |                     | If authed: show profile    |
+-----------------+---------------------+-----------------------------+
```

---

## 13. Migration Phases

### Phase Overview

```
+------------------------------------------------------------------+
|                IMPLEMENTATION PHASES                              |
+------------------------------------------------------------------+
|                                                                  |
|  PHASE 1: Foundation (Infrastructure)            ~2 days         |
|  +----------------------------------------------------------+  |
|  |  - New Listing model with fromJson/toJson                |  |
|  |  - Dio client setup with interceptors                    |  |
|  |  - Server URL settings screen                            |  |
|  |  - Connectivity monitoring provider                      |  |
|  |  - Hive cache setup                                      |  |
|  |  - Android cleartext traffic config                      |  |
|  |  - Repository interfaces (abstract)                      |  |
|  +----------------------------------------------------------+  |
|                                                                  |
|  PHASE 2: Data Layer (Services + Repositories)   ~2 days         |
|  +----------------------------------------------------------+  |
|  |  - ApiCarService implementation                           |  |
|  |  - MockCarService (wraps current mock data)               |  |
|  |  - CarRepository (switches API/mock based on connection)  |  |
|  |  - ConfigService + ConfigRepository                       |  |
|  |  - Cache read/write logic                                 |  |
|  |  - Data transformation (backend JSON -> Flutter model)    |  |
|  +----------------------------------------------------------+  |
|                                                                  |
|  PHASE 3: Screen Integration                     ~3 days         |
|  +----------------------------------------------------------+  |
|  |  - Update Home screen to use repositories                 |  |
|  |  - Update Search screen with real filters                 |  |
|  |  - Update Car Detail with full listing data               |  |
|  |  - Image loading with cached_network_image                |  |
|  |  - Wishlist persistence in Hive                           |  |
|  |  - Profile with auth state                                |  |
|  |  - Offline mode indicators                                |  |
|  +----------------------------------------------------------+  |
|                                                                  |
|  PHASE 4: Authentication                         ~2 days         |
|  +----------------------------------------------------------+  |
|  |  - Login screen                                           |  |
|  |  - Register screen                                        |  |
|  |  - Auth state management                                  |  |
|  |  - Cookie/token handling                                  |  |
|  |  - Protected routes (test drive, contact dealer)          |  |
|  |  - Auth interceptor (auto-refresh)                        |  |
|  +----------------------------------------------------------+  |
|                                                                  |
|  PHASE 5: Polish & Testing                       ~2 days         |
|  +----------------------------------------------------------+  |
|  |  - Error states for all screens                           |  |
|  |  - Loading states (skeleton shimmer)                      |  |
|  |  - Pull-to-refresh                                        |  |
|  |  - Network error recovery                                 |  |
|  |  - Test on real device with backend                       |  |
|  |  - Test offline mode                                      |  |
|  |  - Test slow network                                      |  |
|  +----------------------------------------------------------+  |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 14. File Structure Changes

```
+------------------------------------------------------------------+
|           NEW/MODIFIED FILES                                     |
+------------------------------------------------------------------+
|                                                                  |
|  lib/                                                            |
|  ├── models/                                                     |
|  │   ├── listing.dart              ** NEW (full backend model)   |
|  │   ├── category.dart             ** NEW                        |
|  │   ├── filter_definition.dart    ** NEW                        |
|  │   ├── site_config.dart          ** NEW                        |
|  │   ├── auth_state.dart           ** NEW                        |
|  │   ├── car.dart                  (KEEP as legacy/mock)         |
|  │   ├── brand.dart                (KEEP)                        |
|  │   ├── user.dart                 ** MODIFY (add fromJson)      |
|  │   └── mock_data.dart            (KEEP as fallback)            |
|  │                                                               |
|  ├── services/                     ** NEW DIRECTORY              |
|  │   ├── api/                                                    |
|  │   │   ├── dio_client.dart       ** NEW (Dio setup)            |
|  │   │   ├── api_car_service.dart  ** NEW                        |
|  │   │   ├── api_auth_service.dart ** NEW                        |
|  │   │   └── api_config_service.dart ** NEW                      |
|  │   ├── mock/                                                   |
|  │   │   └── mock_car_service.dart ** NEW (wraps mock_data)      |
|  │   └── interfaces/                                             |
|  │       ├── car_service.dart      ** NEW (abstract)             |
|  │       ├── auth_service.dart     ** NEW (abstract)             |
|  │       └── config_service.dart   ** NEW (abstract)             |
|  │                                                               |
|  ├── repositories/                 ** NEW DIRECTORY              |
|  │   ├── car_repository.dart       ** NEW                        |
|  │   ├── auth_repository.dart      ** NEW                        |
|  │   └── config_repository.dart    ** NEW                        |
|  │                                                               |
|  ├── providers/                                                  |
|  │   ├── app_provider.dart         ** MAJOR REWRITE              |
|  │   ├── connectivity_provider.dart ** NEW                       |
|  │   ├── auth_provider.dart        ** NEW                        |
|  │   └── config_provider.dart      ** NEW                        |
|  │                                                               |
|  ├── screens/                                                    |
|  │   ├── settings_screen.dart      ** NEW (server URL config)    |
|  │   ├── login_screen.dart         ** NEW                        |
|  │   ├── register_screen.dart      ** NEW                        |
|  │   ├── home_screen.dart          ** MODIFY (use repositories)  |
|  │   ├── search_screen.dart        ** MODIFY (real filters)      |
|  │   ├── car_detail_screen.dart    ** MODIFY (full listing)      |
|  │   ├── wishlist_screen.dart      ** MODIFY (Hive persistence)  |
|  │   └── profile_screen.dart       ** MODIFY (auth state)        |
|  │                                                               |
|  ├── widgets/                                                    |
|  │   └── car/                                                    |
|  │       ├── car_image.dart        ** NEW (cached image widget)  |
|  │       └── offline_banner.dart   ** NEW                        |
|  │                                                               |
|  └── utils/                                                      |
|      ├── cache_manager.dart        ** NEW (Hive helpers)         |
|      └── formatters.dart           ** MODIFY (INR formatting)    |
|                                                                  |
|  android/app/src/main/                                           |
|  └── AndroidManifest.xml           ** MODIFY (cleartext traffic) |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 15. Testing Strategy

```
+------------------------------------------------------------------+
|              TESTING MATRIX                                      |
+------------------------------------------------------------------+
|                                                                  |
|  SCENARIO                        | EXPECTED BEHAVIOR             |
|  --------------------------------+------------------------------  |
|  App launch, no server URL       | Shows onboarding, then home   |
|  configured                      | with mock/cached data         |
|  --------------------------------+------------------------------  |
|  App launch, server URL set,     | Fetches live data, caches it, |
|  server reachable                | shows fresh listings          |
|  --------------------------------+------------------------------  |
|  App launch, server URL set,     | Shows cached data with        |
|  server unreachable              | "Offline" banner              |
|  --------------------------------+------------------------------  |
|  App launch, server URL set,     | Shows mock data with          |
|  no cache, server unreachable    | "Offline" banner              |
|  --------------------------------+------------------------------  |
|  Browsing, server goes down      | Continues working with cache, |
|  mid-session                     | new requests show errors      |
|  --------------------------------+------------------------------  |
|  Server comes back after being   | Auto-reconnects, refreshes    |
|  down                            | data silently                 |
|  --------------------------------+------------------------------  |
|  Search with live backend        | Debounced API calls, shows    |
|                                  | filtered results              |
|  --------------------------------+------------------------------  |
|  Search while offline            | Filters cached listings only  |
|  --------------------------------+------------------------------  |
|  Tap car detail, image loads     | Shows image from server,      |
|                                  | caches to disk                |
|  --------------------------------+------------------------------  |
|  Tap car detail, image fails     | Shows gradient + brand        |
|                                  | initial placeholder           |
|  --------------------------------+------------------------------  |
|  Toggle wishlist                 | Saves to Hive immediately,    |
|                                  | persists across sessions      |
|  --------------------------------+------------------------------  |
|  Login with valid credentials    | Sets cookies, shows profile   |
|  --------------------------------+------------------------------  |
|  Login with wrong password       | Shows error, stays on login   |
|  --------------------------------+------------------------------  |
|  Access token expires            | Auto-refresh via interceptor, |
|                                  | user doesn't notice           |
|  --------------------------------+------------------------------  |
|  Both tokens expire              | Silent logout, guest mode     |
|  --------------------------------+------------------------------  |
|  Server IP changes               | Settings screen to update URL |
|  --------------------------------+------------------------------  |
|                                                                  |
+------------------------------------------------------------------+
```

---

## 16. Risk Register

```
+====================================================================+
| RISK                          | PROBABILITY | IMPACT | MITIGATION  |
+====================================================================+
| Cookie auth doesn't work      | MEDIUM      | HIGH   | Fallback:   |
| on mobile Dio client          |             |        | Add bearer  |
|                               |             |        | token mode  |
|                               |             |        | to backend  |
+-------------------------------+-------------+--------+-------------+
| Large listing response        | LOW         | MEDIUM | Only fetch  |
| causes memory issues          |             |        | needed       |
| (150+ fields per car)         |             |        | fields in    |
|                               |             |        | model. Lazy  |
|                               |             |        | parse.       |
+-------------------------------+-------------+--------+-------------+
| Server IP changes             | MEDIUM      | LOW    | Settings     |
| frequently                    |             |        | screen.      |
|                               |             |        | Consider     |
|                               |             |        | mDNS later.  |
+-------------------------------+-------------+--------+-------------+
| Cached data becomes stale     | MEDIUM      | LOW    | TTL-based    |
| (car sold but still shown)    |             |        | cache.       |
|                               |             |        | Pull-to-     |
|                               |             |        | refresh.     |
+-------------------------------+-------------+--------+-------------+
| Rate limit hit during         | LOW         | MEDIUM | Debounce     |
| rapid search typing           |             |        | to 500ms.    |
|                               |             |        | Cache search |
|                               |             |        | results.     |
+-------------------------------+-------------+--------+-------------+
| Multiple devices with         | LOW         | LOW    | Wishlist is  |
| different wishlists           |             |        | device-local |
|                               |             |        | (same as     |
|                               |             |        | website).    |
+-------------------------------+-------------+--------+-------------+
| Image cache fills device      | LOW         | LOW    | Set max      |
| storage                       |             |        | cache size   |
|                               |             |        | (200MB).     |
|                               |             |        | LRU eviction.|
+-------------------------------+-------------+--------+-------------+
```

---

## Summary

This plan ensures the SearchAnyCars mobile app integrates with the existing backend **without any backend modifications** for the initial phase. The app will:

1. **Work standalone** with mock/cached data when offline
2. **Connect to the local network backend** when available
3. **Cache all data** for offline browsing
4. **Handle auth via cookies** (with bearer token fallback ready)
5. **Load real car images** with graceful fallback to current placeholder style
6. **Remain loosely coupled** - the backend is a data source, not a hard dependency

The biggest technical challenge is **cookie-based auth on mobile**, which should be tested early in Phase 1 to determine if the fallback bearer token approach is needed.
