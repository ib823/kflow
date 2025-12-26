# KerjaFlow Release Procedure

**Version:** 3.0
**Last Updated:** December 26, 2025

---

## Overview

This document outlines the manual release procedure for KerjaFlow mobile application. Follow these steps in order for each release.

**Release Cycle:** Bi-weekly (every 2 weeks)
**Hotfix Cycle:** As needed (critical bugs only)

---

## 1. Pre-Release Preparation

### 1.1 Version Bump

Update version in the following files:

**1. `mobile/pubspec.yaml`**
```yaml
version: 3.0.1+30001  # format: major.minor.patch+buildNumber
```

**2. `mobile/android/app/build.gradle`**
```groovy
def appVersionName = '3.0.1'
def appVersionCode = 30001
```

**3. `mobile/ios/Runner.xcodeproj/project.pbxproj`**
- Or use Xcode: Target > General > Version & Build

**Version Code Formula:**
```
versionCode = major * 10000 + minor * 100 + patch
Example: 3.0.1 = 3*10000 + 0*100 + 1 = 30001
```

### 1.2 Changelog Update

Update `CHANGELOG.md`:

```markdown
## [3.0.1] - 2025-12-26

### Added
- Feature description

### Changed
- Change description

### Fixed
- Bug fix description

### Security
- Security fix description
```

### 1.3 Code Freeze

```bash
# Create release branch
git checkout main
git pull origin main
git checkout -b release/v3.0.1

# Push release branch
git push -u origin release/v3.0.1
```

---

## 2. Android Build

### 2.1 Environment Setup

```bash
# Verify Flutter installation
flutter doctor -v

# Expected output:
# Flutter 3.24.0
# Dart 3.5.0
# Android SDK 34

# Clean previous builds
cd mobile
flutter clean
flutter pub get
```

### 2.2 Generate Code

```bash
# Run code generation (freezed, json_serializable, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Generate localizations
flutter gen-l10n
```

### 2.3 Setup Signing

```bash
# Ensure keystore exists
ls -la android/keystore/release.keystore

# Ensure key.properties exists (DO NOT COMMIT)
cat android/key.properties
# Should contain:
# storePassword=<password>
# keyPassword=<password>
# keyAlias=kerjaflow-release
# storeFile=keystore/release.keystore
```

### 2.4 Build Google Play Release

```bash
# Build AAB for Google Play Store
flutter build appbundle --release --flavor google \
  --build-name=3.0.1 \
  --build-number=30001

# Output: build/app/outputs/bundle/googleRelease/app-google-release.aab

# Verify AAB
bundletool validate --bundle=build/app/outputs/bundle/googleRelease/app-google-release.aab

# Also build APK for internal testing
flutter build apk --release --flavor google \
  --build-name=3.0.1 \
  --build-number=30001

# Output: build/app/outputs/flutter-apk/app-google-release.apk
```

### 2.5 Build Huawei AppGallery Release

```bash
# Build APK for Huawei AppGallery (no GMS)
flutter build apk --release --flavor huawei \
  --build-name=3.0.1 \
  --build-number=30001 \
  --dart-define=HUAWEI_SERVICES=true

# Output: build/app/outputs/flutter-apk/app-huawei-release.apk
```

### 2.6 Android Build Verification

| Check | Command | Expected |
|-------|---------|----------|
| AAB exists | `ls -la build/app/outputs/bundle/googleRelease/` | `app-google-release.aab` |
| APK exists | `ls -la build/app/outputs/flutter-apk/` | `app-google-release.apk` |
| Huawei APK | `ls -la build/app/outputs/flutter-apk/` | `app-huawei-release.apk` |
| Signing | `jarsigner -verify -verbose build/...apk` | "jar verified" |
| Size | `du -h build/...apk` | < 50 MB |

---

## 3. iOS Build

### 3.1 Environment Setup

```bash
# Verify Xcode version
xcodebuild -version
# Expected: Xcode 15.x

# Verify Flutter iOS
flutter doctor -v

# Clean and get dependencies
cd mobile
flutter clean
flutter pub get

# Install CocoaPods
cd ios
pod install --repo-update
cd ..
```

### 3.2 Generate Code

```bash
# Same as Android
flutter pub run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

### 3.3 Setup Signing (Xcode)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target
3. Go to **Signing & Capabilities**
4. Team: `KerjaFlow Sdn Bhd`
5. Bundle Identifier: `my.kerjaflow.app`
6. Provisioning Profile: `KerjaFlow Distribution`

### 3.4 Build iOS Release

**Option A: Command Line**
```bash
# Build IPA
flutter build ipa --release \
  --build-name=3.0.1 \
  --build-number=30001 \
  --export-options-plist=ios/ExportOptions.plist

# Output: build/ios/ipa/KerjaFlow.ipa
```

**Option B: Xcode (Recommended for first time)**
1. Open `ios/Runner.xcworkspace`
2. Select **Product > Archive**
3. Wait for archive to complete
4. **Distribute App > App Store Connect**
5. Upload to App Store Connect

### 3.5 ExportOptions.plist

Create/verify `ios/ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>XXXXXXXXXX</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>destination</key>
    <string>upload</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>my.kerjaflow.app</key>
        <string>KerjaFlow Distribution</string>
    </dict>
</dict>
</plist>
```

### 3.6 iOS Build Verification

| Check | Method | Expected |
|-------|--------|----------|
| IPA exists | `ls -la build/ios/ipa/` | `KerjaFlow.ipa` |
| Archive valid | Xcode Organizer | Green checkmark |
| No warnings | Xcode Organizer | No red/yellow |
| Size | `du -h build/ios/ipa/*.ipa` | < 100 MB |

---

## 4. Store Submission

### 4.1 Google Play Console

**URL:** https://play.google.com/console

#### Upload AAB
1. Go to **Production > Create new release**
2. Upload `app-google-release.aab`
3. Wait for processing

#### Release Notes
```
KerjaFlow v3.0.1

What's New:
• [Feature 1]
• [Feature 2]

Bug Fixes:
• [Fix 1]
• [Fix 2]

---
Apa yang Baharu (Bahasa Malaysia):
• [Ciri 1]
• [Ciri 2]
```

#### Submission Checklist
| Item | Status |
|------|:------:|
| AAB uploaded | [ ] |
| Release notes (EN) | [ ] |
| Release notes (MS) | [ ] |
| Release notes (ID) | [ ] |
| Screenshots updated (if UI changed) | [ ] |
| Review started | [ ] |

#### Track Options
- **Internal testing:** Immediate, 100 testers
- **Closed testing:** 1 hour, limited testers
- **Open testing:** 1 hour, public
- **Production:** Review (1-3 days)

**Recommended:** Internal → Closed (1 day) → Production

### 4.2 Huawei AppGallery

**URL:** https://developer.huawei.com/consumer/en/appgallery

#### Upload APK
1. Go to **My Apps > KerjaFlow**
2. Click **Update**
3. Upload `app-huawei-release.apk`

#### Submission Checklist
| Item | Status |
|------|:------:|
| APK uploaded | [ ] |
| Release notes (EN) | [ ] |
| Release notes (MS) | [ ] |
| HMS Core integration verified | [ ] |
| Review started | [ ] |

**Review Time:** 1-3 business days

### 4.3 Apple App Store

**URL:** https://appstoreconnect.apple.com

#### Upload via Xcode
1. Open **Xcode > Window > Organizer**
2. Select archive
3. Click **Distribute App**
4. Choose **App Store Connect**
5. Upload

#### Or Upload via Transporter
```bash
xcrun altool --upload-app \
  --file build/ios/ipa/KerjaFlow.ipa \
  --type ios \
  --apiKey <key_id> \
  --apiIssuer <issuer_id>
```

#### App Store Connect
1. Go to **My Apps > KerjaFlow**
2. Click **+ Version or Platform**
3. Enter version `3.0.1`
4. Select uploaded build
5. Fill release notes
6. Submit for Review

#### Submission Checklist
| Item | Status |
|------|:------:|
| Build uploaded | [ ] |
| Build processing complete | [ ] |
| Version number set | [ ] |
| Release notes (EN) | [ ] |
| What's New localized | [ ] |
| Screenshots updated (if needed) | [ ] |
| App Review Information | [ ] |
| Demo account provided | [ ] |
| Submit for Review | [ ] |

**Review Time:** 1-2 business days (usually 24 hours)

---

## 5. Post-Release

### 5.1 Tag Release

```bash
# After all stores approved
git checkout release/v3.0.1
git tag -a v3.0.1 -m "Release v3.0.1"
git push origin v3.0.1

# Merge back to main
git checkout main
git merge release/v3.0.1
git push origin main

# Delete release branch (optional)
git branch -d release/v3.0.1
git push origin --delete release/v3.0.1
```

### 5.2 GitHub Release

1. Go to **Releases > Create new release**
2. Tag: `v3.0.1`
3. Title: `KerjaFlow v3.0.1`
4. Description: Copy from CHANGELOG
5. Attach files:
   - `app-google-release.apk`
   - `app-huawei-release.apk`
   - (IPA via TestFlight only)
6. Publish release

### 5.3 Notify Stakeholders

Send release notification to:
- [ ] Product team
- [ ] Customer success team
- [ ] Support team
- [ ] Enterprise customers (for on-premise)

---

## 6. Rollback Procedure

### If Critical Bug Found Post-Release

#### Google Play
1. Go to **Production > Releases**
2. Click **Halt rollout**
3. Upload previous version with incremented version code

#### Apple App Store
1. Go to **App Store Connect**
2. Remove current version from sale
3. Submit previous version (new build number)

#### Huawei AppGallery
1. Go to **My Apps > KerjaFlow**
2. Click **Take Down**
3. Upload previous version

---

## 7. Hotfix Procedure

For critical production bugs:

```bash
# Create hotfix branch from tag
git checkout v3.0.1
git checkout -b hotfix/v3.0.2

# Fix the bug
# ... make changes ...

# Bump version to 3.0.2
# Update pubspec.yaml, build.gradle

# Commit and push
git add .
git commit -m "fix: [description of fix]"
git push -u origin hotfix/v3.0.2

# Build and test
flutter build appbundle --release --flavor google
flutter build apk --release --flavor huawei
flutter build ipa --release

# After testing, merge to main
git checkout main
git merge hotfix/v3.0.2
git tag -a v3.0.2 -m "Hotfix v3.0.2"
git push origin main --tags

# Submit to stores (expedited review if critical)
```

---

## 8. Release Artifacts Checklist

| Artifact | Location | Retention |
|----------|----------|-----------|
| `app-google-release.aab` | `build/app/outputs/bundle/googleRelease/` | Keep 3 versions |
| `app-google-release.apk` | `build/app/outputs/flutter-apk/` | Keep 3 versions |
| `app-huawei-release.apk` | `build/app/outputs/flutter-apk/` | Keep 3 versions |
| `KerjaFlow.ipa` | `build/ios/ipa/` | Keep 3 versions |
| Release notes | CHANGELOG.md | Forever |
| Git tag | GitHub | Forever |

---

## 9. Secrets Management

### Required Secrets (DO NOT COMMIT)

| Secret | Location | Purpose |
|--------|----------|---------|
| Android Keystore | `android/keystore/release.keystore` | App signing |
| Keystore Password | `android/key.properties` | Unlock keystore |
| Key Password | `android/key.properties` | Unlock key |
| iOS Certificate | Xcode/Keychain | App signing |
| Provisioning Profile | Xcode | Distribution |
| Play Console API Key | Local only | Fastlane (optional) |
| App Store API Key | Local only | Transporter (optional) |

### Backup Secrets

Store encrypted copies in:
- Password manager (1Password/Bitwarden)
- Secure company vault
- NOT in git, NOT in plaintext files

---

## 10. Quick Reference

### Version Bump Commands
```bash
# Patch release (bug fixes): 3.0.0 → 3.0.1
# Minor release (features): 3.0.0 → 3.1.0
# Major release (breaking): 3.0.0 → 4.0.0
```

### Build Commands Summary
```bash
# Clean build
flutter clean && flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs
flutter gen-l10n

# Android Google
flutter build appbundle --release --flavor google

# Android Huawei
flutter build apk --release --flavor huawei --dart-define=HUAWEI_SERVICES=true

# iOS
cd ios && pod install && cd ..
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

### Store URLs
| Store | Console URL |
|-------|-------------|
| Google Play | https://play.google.com/console |
| App Store | https://appstoreconnect.apple.com |
| Huawei | https://developer.huawei.com/consumer/en/appgallery |

---

## Release Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Developer | | | |
| QA Lead | | | |
| Product Owner | | | |

**Release Version:** ___________
**Release Date:** ___________

---

*Document Version: 3.0*
*Maintained by KerjaFlow Engineering Team*
