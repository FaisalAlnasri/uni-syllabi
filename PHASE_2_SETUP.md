# Phase 2 — Auth Setup (per new app)

Phase 2 ships Google + Apple sign-in, a splash/login/onboarding flow, and a
router guard. The Dart code is template-ready; the steps below are the **manual,
per-app** wiring you must do each time you start a new app from this template.

Until you finish "Firebase project" + "flutterfire configure", the app will
throw `[core/no-app] No Firebase App '[DEFAULT]' has been created` on launch,
because the auth stream touches `FirebaseAuth.instance` at startup.

---

## 1. Firebase project

1. Create a project at <https://console.firebase.google.com>.
2. Add an **Android** app (use your final `applicationId`, e.g. `com.company.app`).
3. Add an **iOS** app (use your final bundle ID).
4. In **Build → Authentication → Sign-in method**, enable:
   - **Google**
   - **Apple** (iOS only)

## 2. flutterfire configure

Generates `firebase_options_*.dart` and wires native config. Run from the
project root:

```bash
dart pub global activate flutterfire_cli   # once per machine
flutterfire configure
```

Then in **both** `lib/main_dev.dart` and `lib/main_prod.dart`:

- Uncomment the `firebase_options_*` import.
- Uncomment / fill `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
- In `main_dev.dart`, uncomment the `await Firebase.initializeApp(...)` block
  (it is intentionally commented out in the template).

> Tip: if you keep separate dev/prod Firebase projects, run `flutterfire
> configure` twice into `firebase_options_dev.dart` / `firebase_options_prod.dart`
> and import the matching one per entrypoint.

## 3. Google Sign-In

### Android
- `flutterfire configure` adds `google-services.json`. Confirm the Gradle
  plugin is applied (newer Flutter templates do this automatically).
- Add your debug + release **SHA-1 / SHA-256** fingerprints in Firebase
  Console → Project settings → your Android app, then re-download
  `google-services.json`. Google Sign-In fails silently without the SHA-1.
  ```bash
  cd android && ./gradlew signingReport
  ```

### iOS
- Open `ios/Runner/Info.plist` and add the **reversed client ID** URL scheme
  from `GoogleService-Info.plist` (the `REVERSED_CLIENT_ID` value):
  ```xml
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>REVERSED_CLIENT_ID_FROM_GoogleService-Info.plist</string>
      </array>
    </dict>
  </array>
  ```

### OAuth consent screen
- In Google Cloud Console (the project Firebase created) → **APIs & Services →
  OAuth consent screen**: set app name, support email, and developer contact.
- Add the app logo / domains before going to production, or Google may block
  non-test users.

## 4. Apple Sign-In (iOS)

- In **Xcode → Runner → Signing & Capabilities**, add the
  **Sign in with Apple** capability.
- In the **Apple Developer portal** → Identifiers → your App ID, enable
  **Sign in with Apple**.
- In **Firebase Console → Authentication → Apple**, the default config is
  enough for iOS-only. (Android / web Apple sign-in needs a Services ID +
  private key — out of scope for the default template.)
- Apple returns the user's name **only on the first authorization**; the
  service patches it onto the Firebase profile on first sign-in.

## 5. RevenueCat keys (carried over from config)

`AppConfig.setup()` already takes `revenueCatApiKey`. Replace the placeholders:

- `lib/main_dev.dart`  → `revenueCatApiKey: 'YOUR_RC_DEV_KEY'`
- `lib/main_prod.dart` → `revenueCatApiKey: 'YOUR_RC_PROD_KEY'`

(Wiring the RevenueCat SDK itself is Phase 3.)

## 6. Auth behavior flags

Set per app in both `main_*.dart` `AppConfig.setup(...)`:

| Flag            | Effect when `true`                                        | When `false`                                  |
| --------------- | --------------------------------------------------------- | --------------------------------------------- |
| `requiresAuth`  | Signed-out users are redirected to `/login`.              | Signed-out users become **guests** (`/home`). |
| `hasOnboarding` | First post-login launch routes through `/onboarding`.     | Skips onboarding straight to `/home`.         |

Onboarding completion is persisted via `OnboardingStorage` (SharedPreferences).

---

## Verify the flow

With Firebase configured:

1. `flutter run -t lib/main_dev.dart`
2. App opens on **splash** → resolves to **login** (since `requiresAuth: true`).
3. Sign in with Google (or Apple on iOS) → **onboarding** → tap **ابدأ** → **home**.
4. Relaunch → goes straight to **home** (session + onboarding persisted).
