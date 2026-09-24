# PAMOJI — User App (Flutter)

The customer mobile application for the PAMOJI Marketplace (Malawi). Buyers
and sellers in ONE app, one account. Independent from the admin panel
(pamoji-admin-panel); both use the same Base44 backend — there is no separate
backend repo by owner decision: Base44 IS the backend (entity tables,
authentication, realtime-capable data, deployed edge functions).

Backend base URL: https://lyra-d13d23f6.base44.app/functions

## What's implemented (v1.0.0 — everything below is REAL, verified against the live backend)
1. Email/password registration with marketplace location picker (no GPS exposure).
2. Email verification flow (DEV code shown in-app until an email provider is
   configured — documented gap, not faked).
3. Login / logout / persistent encrypted session (flutter_secure_storage).
4. Home feed: categories, featured and new listings from the live catalog.
5. Search with filters: category, condition, location, price sorting.
6. Listing details: gallery, price, condition, seller card with verified
   badge, rating, WhatsApp deep link, real report flow, favorite toggle.
7. Favorites list (synced to your account).
8. Profile with account status and real in-app notifications.
9. Optimistic UI, skeleton loaders, retry/offline-friendly error states,
   image caching, pagination limits — built for poor Malawi networks.

## Honest next phases (backend FULLY supports these; UI not built yet — no fake screens)
1. Seller onboarding + verification submission UI (backend ready: pamojiSeller).
2. Create/edit listing UI with image pipeline (backend ready: pamojiListing +
   pamojiMedia; storage provider documented in admin panel docs/).
3. Chat UI (backend ready: pamojiChat — conversations already start for real).
4. Cart + checkout + order tracking UI (backend ready: pamojiOrders).
5. Reviews UI (backend ready: pamojiReviews).

## Build & install
Requires Flutter 3.22+. `flutter pub get && flutter run` for dev, or grab the
signed release APK from GitHub Releases (built by CI with the owner's
keystore). Signed with the owner's proven release keystore — updates must use
the same key.

## Data contracts
Field names, types and statuses match the shared contracts in
pamoji-admin-panel/docs/contracts.md — both apps must stay in sync with the
deployed Base44 functions (also versioned in pamoji-admin-panel/backend/).
