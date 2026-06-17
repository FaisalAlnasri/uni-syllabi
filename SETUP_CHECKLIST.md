# New App Setup Checklist

## Step 1 — Rename the template
- [X] Run: `bash rename.sh com.yourname.appname "اسم التطبيق"`
- [X] Run `flutter pub get`
- [X] Commit: `chore(init): rename template to <appname>`

## Step 2 — Theme
- [ ] Open `lib/core/theme/app_colors.dart`
- [ ] Change `seed` color to your app's primary color
- [ ] Open `lib/core/theme/app_text_styles.dart`
- [ ] Confirm font family matches your chosen font (default: Cairo)
- [ ] Add font files to `assets/fonts/` or switch to `google_fonts`
- [ ] Commit: `chore(theme): set brand colors and font`

## Step 3 — Firebase
- [ ] Go to console.firebase.google.com → create a new project
- [ ] Add an Android app — use your bundle ID from Step 1
- [ ] Add an iOS app — use the same bundle ID
- [ ] Enable Authentication → Google provider → add your SHA-1 + SHA-256
- [ ] Enable Authentication → Apple provider
- [ ] Download `google-services.json` → place in `android/app/`
- [ ] Run: `flutterfire configure` → select your new project → generates `lib/firebase_options.dart`
- [ ] In `main_dev.dart` and `main_prod.dart`, uncomment `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
- [ ] Commit: `chore(firebase): add firebase config for <appname>`

## Step 4 — Android: Google Sign-In SHA fingerprints
- [ ] Run: `keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android` (Windows) or `~/.android/debug.keystore` (Mac/Linux)
- [ ] Copy SHA-1 and SHA-256 → Firebase Console → Project Settings → Android app → Add fingerprint
- [ ] Re-download `google-services.json` and replace `android/app/google-services.json`
- [ ] Re-run `flutterfire configure`

## Step 5 — iOS: Apple Sign-In
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Runner target → Signing & Capabilities → + Capability → Sign In with Apple
- [ ] Go to developer.apple.com → Identifiers → your App ID → enable Sign In with Apple → Save
- [ ] Firebase Console → Authentication → Apple → copy the OAuth callback URL
- [ ] developer.apple.com → your App ID → Sign In with Apple → Configure → add the callback URL as return URL
- [ ] Commit: `chore(ios): enable apple sign-in capability`

## Step 6 — RevenueCat
- [ ] Go to app.revenuecat.com → create a new project
- [ ] Add iOS app → enter bundle ID → enter App Store Connect API key
- [ ] Add Android app → enter bundle ID → enter Play Store credentials
- [ ] Create a Product in App Store Connect and Play Console (subscription)
- [ ] Back in RC → Products → add your product IDs
- [ ] RC → Entitlements → create one (e.g. `premium`) → attach your products
- [ ] RC → Offerings → create one → add a Package → attach entitlement
- [ ] Copy your RC API keys (iOS + Android — they differ)
- [ ] Open `lib/main_dev.dart` and `lib/main_prod.dart`:
      - Set `revenueCatApiKey` to your RC key (use dev key in dev, prod key in prod)
      - Set `revenueCatEntitlementId` to match your RC entitlement ID (e.g. `'premium'`)
- [ ] Commit: `chore(revenuecat): set RC keys and entitlement ID`

## Step 7 — Paywall copy
- [ ] Open `lib/features/paywall/presentation/pages/paywall_page.dart`
- [ ] Update title, subtitle, and benefit strings to match your app
- [ ] Commit: `feat(paywall): set paywall copy for <appname>`

## Step 8 — AppConfig flags
- [ ] Open `lib/main_dev.dart` and `lib/main_prod.dart`
- [ ] Set `requiresAuth: true` or `false` based on whether your app requires login
- [ ] Set `hasOnboarding: true` or `false` based on whether you have an onboarding flow
- [ ] If `hasOnboarding: true`, build out `lib/features/onboarding/presentation/pages/onboarding_page.dart`
- [ ] Commit: `chore(config): set auth and onboarding flags`

## Step 9 — App icons + splash screen
- [ ] Replace `assets/icon/` with your app icon (1024x1024 PNG, no alpha)
- [ ] Use `flutter_launcher_icons` package to generate all sizes
- [ ] Replace splash screen assets
- [ ] Use `flutter_native_splash` package to generate splash
- [ ] Commit: `chore(assets): add app icon and splash screen`

## Step 10 — First run check
- [ ] `flutter clean && flutter pub get`
- [ ] Run dev: `flutter run -t lib/main_dev.dart`
- [ ] Confirm: splash → login → Google Sign-In → home with premium card
- [ ] Confirm: tap premium card → paywall opens
- [ ] Run on iOS simulator: confirm Apple Sign-In button appears
- [ ] `flutter analyze` — zero issues

## Step 11 — Store setup (when ready to release)
- [ ] App Store Connect: create app record, set bundle ID, add screenshots
- [ ] Play Console: create app, set package name, upload first AAB
- [ ] Set up signing: iOS distribution certificate + provisioning profile, Android keystore
- [ ] Update `android/app/build.gradle.kts` release `signingConfig` with your keystore
