# rename.ps1 - Rename this template for a new app.
#
# Run ONCE when starting a new project from this template.
#
# Usage:
#   .\rename.ps1 com.yourname.appname "App Name"
#
# If PowerShell blocks the script the first time, run this once:
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#
# The new package name is derived automatically from the last segment of the
# bundle ID (lowercased). The current bundle ID is read from
# android/app/build.gradle.kts - you do not pass it in.
#
# This script is idempotent: running it twice does not corrupt any file.

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$NewId,

    [Parameter(Mandatory=$true, Position=1)]
    [string]$AppName
)

$ErrorActionPreference = "Stop"

$GradleFile = "android/app/build.gradle.kts"
$Pubspec    = "pubspec.yaml"
$AppConfig  = "lib/core/config/app_config.dart"

# ---------------------------------------------------------------------------
# Read current values (must happen BEFORE we modify anything - keeps the
# script idempotent because the second run reads the already-updated values).
# ---------------------------------------------------------------------------
$gradleContent = Get-Content $GradleFile -Raw
$oldIdMatch = [regex]::Match($gradleContent, 'applicationId\s*=\s*"([^"]+)"')
if (-not $oldIdMatch.Success) {
    Write-Error "Could not find applicationId in $GradleFile"
    exit 1
}
$OldId = $oldIdMatch.Groups[1].Value

$pubspecContent = Get-Content $Pubspec -Raw
$oldPkgMatch = [regex]::Match($pubspecContent, '(?m)^name:\s*(\S+)')
if (-not $oldPkgMatch.Success) {
    Write-Error "Could not find name: field in $Pubspec"
    exit 1
}
$OldPkg = $oldPkgMatch.Groups[1].Value.Trim()

# Derive the new Dart package name from the last segment of the bundle ID.
# Lowercase it and replace any character that is not valid in a Dart package
# name with an underscore. Example: com.faisal.MyApp -> myapp
$lastSegment = $NewId.Split('.')[-1].ToLower()
$NewPkg = [regex]::Replace($lastSegment, '[^a-z0-9_]', '_')

Write-Host "Renaming template:"
Write-Host "  Bundle ID:    $OldId  ->  $NewId"
Write-Host "  Package name: $OldPkg  ->  $NewPkg"
Write-Host "  App name:     $AppName"
Write-Host ""

# ---------------------------------------------------------------------------
# 1. pubspec.yaml - name field
# ---------------------------------------------------------------------------
$pubspecContent = [regex]::Replace($pubspecContent, '(?m)^name:.*', "name: $NewPkg")
Set-Content -Path $Pubspec -Value $pubspecContent -NoNewline -Encoding UTF8
Write-Host "[OK] Updated pubspec.yaml"

# ---------------------------------------------------------------------------
# 2. android/app/build.gradle.kts - namespace + applicationId
#    Match any existing quoted value so re-runs stay idempotent.
# ---------------------------------------------------------------------------
$gradleContent = [regex]::Replace($gradleContent, 'namespace\s*=\s*"[^"]*"', "namespace = `"$NewId`"")
$gradleContent = [regex]::Replace($gradleContent, 'applicationId\s*=\s*"[^"]*"', "applicationId = `"$NewId`"")
Set-Content -Path $GradleFile -Value $gradleContent -NoNewline -Encoding UTF8
Write-Host "[OK] Updated android/app/build.gradle.kts"

# ---------------------------------------------------------------------------
# 3 & 4. AndroidManifest.xml files - package="..." only if present.
#    Modern Flutter uses the gradle namespace instead, so these usually
#    have no package attribute; we update it only when it exists.
# ---------------------------------------------------------------------------
foreach ($variant in @("main", "debug", "profile")) {
    $manifest = "android/app/src/$variant/AndroidManifest.xml"
    if (Test-Path $manifest) {
        $manifestContent = Get-Content $manifest -Raw
        if ($manifestContent -match 'package="[^"]*"') {
            $manifestContent = [regex]::Replace($manifestContent, 'package="[^"]*"', "package=`"$NewId`"")
            Set-Content -Path $manifest -Value $manifestContent -NoNewline -Encoding UTF8
            Write-Host "[OK] Updated $manifest"
        }
    }
}

# ---------------------------------------------------------------------------
# 5. lib/core/config/app_config.dart - appName for both Env branches.
#    The original line has no trailing semicolon (it is a cascade), so the
#    replacement must not add one. Indentation is preserved because the match
#    starts at "..appName".
# ---------------------------------------------------------------------------
$appConfigContent = Get-Content $AppConfig -Raw
$replacement = "..appName = env == Env.dev ? '$AppName (Dev)' : '$AppName'"
$appConfigContent = [regex]::Replace($appConfigContent, '\.\.appName = .*', $replacement)
Set-Content -Path $AppConfig -Value $appConfigContent -NoNewline -Encoding UTF8
Write-Host "[OK] Updated lib/core/config/app_config.dart"

# ---------------------------------------------------------------------------
# 6. All .dart files under lib/ - update the package import prefix.
# ---------------------------------------------------------------------------
if ($OldPkg -ne $NewPkg) {
    $dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse |
        Where-Object { (Get-Content $_.FullName -Raw) -match [regex]::Escape("package:$OldPkg/") }

    foreach ($file in $dartFiles) {
        $content = Get-Content $file.FullName -Raw
        $content = $content -replace [regex]::Escape("package:$OldPkg/"), "package:$NewPkg/"
        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
    }
    Write-Host "[OK] Updated package imports in lib/ ($OldPkg -> $NewPkg)"
} else {
    Write-Host "[OK] Package imports already use $NewPkg (nothing to do)"
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Done. The template has been renamed."
Write-Host ""
Write-Host "Next steps (still need manual setup):"
Write-Host "  - Run: flutter pub get"
Write-Host "  - Follow SETUP_CHECKLIST.md step by step (Firebase, RevenueCat,"
Write-Host "    sign-in capabilities, icons, splash, store setup)."
Write-Host ""
Write-Host "See SETUP_CHECKLIST.md for the full checklist."