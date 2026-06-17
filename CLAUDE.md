# CLAUDE.md

Guidance for working in this repository.

## Project

Flutter template for Arabic-first, RTL freemium apps (Firebase Auth, RevenueCat
paywall, BLoC, GoRouter, GetIt). Use it as the starting point for new apps.

## Commit conventions

Use Conventional Commits: `type(scope): summary`.
Examples: `chore(init): ...`, `feat(paywall): ...`, `docs(setup): ...`.

## Starting a New App from This Template

When asked to help start a new app or rename the template:
1. Run `bash rename.sh <bundle_id> "<app_name_arabic>"` first
2. Do not manually edit bundle IDs in individual files — the script handles it
3. After renaming, remind the developer to follow SETUP_CHECKLIST.md step by step
4. Do not run `flutterfire configure` — that requires the developer's Firebase account
5. Do not commit Firebase config files (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) — these are per-project and should be in `.gitignore`
