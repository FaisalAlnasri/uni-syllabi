# Phase 3 — RevenueCat + Paywall Setup (per new app)

Phase 3 adds in-app subscriptions via RevenueCat and a full-screen paywall.
The Dart side is template-ready; the steps below are the **manual, per-app**
wiring needed each time you start a new app from this template.

Until you complete the RevenueCat dashboard + store setup and drop in real API
keys, `fetchOffering()` returns `لا توجد عروض متاحة` (no offerings) and the
paywall shows the retry state — the app still runs.

---

## 0. Where the code touches RevenueCat

| Concern                | Location                                                        |
| ---------------------- | -------------------------------------------------------------- |
| API key (dev/prod)     | `AppConfig.setup(revenueCatApiKey: ...)` in `main_*.dart`       |
| Entitlement ID         | `AppConfig.setup(revenueCatEntitlementId: 'premium')`           |
| SDK init               | `_registerPaywall()` in `lib/core/di/service_locator.dart`      |
| All RC SDK calls       | `lib/features/paywall/data/purchases_repository_impl.dart`      |
| Open paywall anywhere  | `context.push(AppRoutes.paywall)`                               |
| Check status anywhere  | `sl<PurchasesRepository>().isSubscriber`                        |

---

## 1. Create a RevenueCat project

1. Sign up / log in at <https://app.revenuecat.com>.
2. **Create a new project** (one project per app; it holds both iOS + Android).

## 2. Add platform apps in RevenueCat

In **Project settings → Apps**:

- **Add App (Apple App Store)** — enter your iOS bundle ID. Upload an
  **App Store Connect API key** (or a shared secret) so RC can validate
  receipts.
- **Add App (Google Play Store)** — enter your Android package name. Upload the
  **Play service-account credentials JSON** with the right permissions.

Each platform app gives you a **public SDK API key** (starts with `appl_` for
Apple, `goog_` for Google). These go into `main_*.dart`:

```dart
// lib/main_dev.dart  /  lib/main_prod.dart
revenueCatApiKey: 'appl_xxx_or_goog_xxx',
```

> If you ship a single binary per platform you can use one key per build flavor.
> RC also supports a platform-agnostic key — use whichever matches your setup.

## 3. Create store products (App Store Connect / Play Console)

RevenueCat surfaces products that exist in the stores — create them first.

### App Store Connect
- **Apps → your app → Subscriptions** (or In-App Purchases).
- Create a **subscription group**, then a subscription product
  (e.g. `premium_monthly`). Set price, and a free trial / intro offer if wanted.
- Fill in localized display name + review screenshot so it's approvable.

### Google Play Console
- **Monetize → Products → Subscriptions**.
- Create a subscription (e.g. `premium_monthly`) with a base plan and price;
  add a free-trial offer if wanted.

> The product IDs do **not** need to match across stores — RC maps them to a
> shared entitlement in the next step.

## 4. Entitlement + Offering in RevenueCat

This is what the app actually checks against.

1. **Entitlements → New** → identifier **`premium`**.
   - This must match `revenueCatEntitlementId` in `AppConfig.setup(...)`
     (the template default is `'premium'`).
2. **Products** → import/add your App Store + Play products, then **attach** each
   one to the `premium` entitlement.
3. **Offerings → New** (e.g. `default`) and mark it **current**.
   - Add a **package** (e.g. Monthly) pointing at the store products.
   - The paywall loads `offerings.current?.availablePackages.first`, so the
     **current** offering must have at least one package.

## 5. Drop in the keys + entitlement ID

```dart
// lib/main_dev.dart
AppConfig.setup(
  env: Env.dev,
  revenueCatApiKey: 'YOUR_RC_DEV_KEY',     // ← appl_ / goog_ public SDK key
  revenueCatEntitlementId: 'premium',      // ← matches RC entitlement
  requiresAuth: true,
  hasOnboarding: true,
);
```

Repeat in `lib/main_prod.dart` with the production key.

## 6. Native store config (already covered by Firebase auth setup, plus)

- **iOS:** In-App Purchase capability is added automatically for StoreKit; make
  sure the app is signed with a provisioning profile whose App ID has IAP
  enabled. Test with a **Sandbox Apple ID** (Settings → App Store → Sandbox).
- **Android:** upload at least an **internal testing** build to Play so the
  Billing Library can see products; add license testers in Play Console. Real
  prices only appear for builds installed via Play (not `flutter run`).

---

## Verify the flow

With a current offering and at least one package configured:

1. `flutter run -t lib/main_dev.dart` on a real device (StoreKit/Billing don't
   fully work on simulators/emulators for purchases).
2. From any screen call `context.push(AppRoutes.paywall)`.
3. Paywall loads → shows price card → tap **اشترك الآن** → store sheet →
   complete with a sandbox/test account.
4. On success: success snackbar + the paywall pops. `sl<PurchasesRepository>()
   .isSubscriber` is now `true`.
5. **استعادة المشتريات** restores an existing entitlement on a fresh install.

### Gating premium features

```dart
if (sl<PurchasesRepository>().isSubscriber) {
  // unlock premium feature
} else {
  context.push(AppRoutes.paywall);
}
```

> `isSubscriber` is refreshed on `init()`, after every purchase, and after
> restore. For live updates elsewhere you can call `Purchases.getCustomerInfo()`
> or add a customer-info listener in a later phase.
