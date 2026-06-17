#!/usr/bin/env bash
#
# rename.sh — Rename this template for a new app.
#
# Run ONCE when starting a new project from this template.
#
# Usage:
#   bash rename.sh com.yourname.appname "اسم التطبيق"
#
# The new package name is derived automatically from the last segment of the
# bundle ID (lowercased). The current bundle ID is read from
# android/app/build.gradle.kts — you do not pass it in.
#
# This script is idempotent: running it twice does not corrupt any file.

set -euo pipefail

# ---------------------------------------------------------------------------
# Argument check
# ---------------------------------------------------------------------------
if [ "$#" -ne 2 ]; then
  echo "Usage: bash rename.sh <bundle_id> \"<app_name_arabic>\""
  echo "Example: bash rename.sh com.yourname.appname \"اسم التطبيق\""
  exit 1
fi

NEW_ID="$1"
APP_NAME="$2"

GRADLE_FILE="android/app/build.gradle.kts"
PUBSPEC="pubspec.yaml"
APP_CONFIG="lib/core/config/app_config.dart"

# ---------------------------------------------------------------------------
# Cross-platform in-place sed (GNU on Linux, BSD on macOS)
# ---------------------------------------------------------------------------
if sed --version >/dev/null 2>&1; then
  # GNU sed (Linux)
  sed_inplace() { sed -i "$@"; }
else
  # BSD sed (macOS)
  sed_inplace() { sed -i '' "$@"; }
fi

# ---------------------------------------------------------------------------
# Read current values (must happen BEFORE we modify anything — keeps the
# script idempotent because the second run reads the already-updated values).
# ---------------------------------------------------------------------------
OLD_ID=$(grep -E 'applicationId[[:space:]]*=' "$GRADLE_FILE" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
OLD_PKG=$(grep -E '^name:' "$PUBSPEC" | head -1 | sed -E 's/^name:[[:space:]]*//' | tr -d '[:space:]')

# Derive the new Dart package name from the last segment of the bundle ID.
# Lowercase it and replace any character that is not valid in a Dart package
# name with an underscore. Example: com.faisal.MyApp -> myapp
NEW_PKG=$(echo "$NEW_ID" | awk -F. '{print $NF}' | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9_]/_/g')

echo "Renaming template:"
echo "  Bundle ID:    $OLD_ID  ->  $NEW_ID"
echo "  Package name: $OLD_PKG  ->  $NEW_PKG"
echo "  App name:     $APP_NAME"
echo ""

# ---------------------------------------------------------------------------
# 1. pubspec.yaml — name field
# ---------------------------------------------------------------------------
sed_inplace -E "s/^name:.*/name: $NEW_PKG/" "$PUBSPEC"
echo "✓ Updated pubspec.yaml"

# ---------------------------------------------------------------------------
# 2. android/app/build.gradle.kts — namespace + applicationId
#    Match any existing quoted value so re-runs stay idempotent.
# ---------------------------------------------------------------------------
sed_inplace -E "s/namespace = \"[^\"]*\"/namespace = \"$NEW_ID\"/" "$GRADLE_FILE"
sed_inplace -E "s/applicationId = \"[^\"]*\"/applicationId = \"$NEW_ID\"/" "$GRADLE_FILE"
echo "✓ Updated android/app/build.gradle.kts"

# ---------------------------------------------------------------------------
# 3 & 4. AndroidManifest.xml files — package="..." only if present.
#    Modern Flutter uses the gradle namespace instead, so these usually
#    have no package attribute; we update it only when it exists.
# ---------------------------------------------------------------------------
for variant in main debug profile; do
  manifest="android/app/src/$variant/AndroidManifest.xml"
  if [ -f "$manifest" ] && grep -q 'package="' "$manifest"; then
    sed_inplace -E "s/package=\"[^\"]*\"/package=\"$NEW_ID\"/" "$manifest"
    echo "✓ Updated $manifest"
  fi
done

# ---------------------------------------------------------------------------
# 5. lib/core/config/app_config.dart — appName for both Env branches.
#    The original line has no trailing semicolon (it is a cascade), so the
#    replacement must not add one. Indentation is preserved because the match
#    starts at "..appName".
# ---------------------------------------------------------------------------
sed_inplace -E "s|\.\.appName = .*|..appName = env == Env.dev ? '$APP_NAME (Dev)' : '$APP_NAME'|" "$APP_CONFIG"
echo "✓ Updated lib/core/config/app_config.dart"

# ---------------------------------------------------------------------------
# 6. All .dart files under lib/ — update the package import prefix.
# ---------------------------------------------------------------------------
if [ "$OLD_PKG" != "$NEW_PKG" ]; then
  FILES=$(grep -rl "package:$OLD_PKG/" lib/ || true)
  if [ -n "$FILES" ]; then
    echo "$FILES" | while IFS= read -r file; do
      sed_inplace -E "s|package:$OLD_PKG/|package:$NEW_PKG/|g" "$file"
    done
  fi
  echo "✓ Updated package imports in lib/ ($OLD_PKG -> $NEW_PKG)"
else
  echo "✓ Package imports already use $NEW_PKG (nothing to do)"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "Done. The template has been renamed."
echo ""
echo "Next steps (still need manual setup):"
echo "  • Run: flutter pub get"
echo "  • Follow SETUP_CHECKLIST.md step by step (Firebase, RevenueCat,"
echo "    sign-in capabilities, icons, splash, store setup)."
echo ""
echo "See SETUP_CHECKLIST.md for the full checklist."
