# KerjaFlow Android Keystore Setup

## Overview

This directory contains documentation for Android release signing. The actual keystore file (`release.keystore`) and credentials should **NEVER** be committed to version control.

## Generating the Release Keystore

### 1. Generate Keystore (One-time setup)

```bash
keytool -genkey -v \
  -keystore release.keystore \
  -alias kerjaflow \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass <STORE_PASSWORD> \
  -keypass <KEY_PASSWORD> \
  -dname "CN=KerjaFlow, OU=Mobile, O=KerjaFlow Sdn Bhd, L=Kuala Lumpur, ST=WP, C=MY"
```

### 2. Create key.properties File

Create `android/key.properties` (not committed to git):

```properties
storePassword=<STORE_PASSWORD>
keyPassword=<KEY_PASSWORD>
keyAlias=kerjaflow
storeFile=keystore/release.keystore
```

### 3. Verify Keystore

```bash
keytool -list -v -keystore release.keystore -alias kerjaflow
```

## CI/CD Secrets Configuration

Store the following secrets in GitHub Actions:

| Secret Name | Description |
|-------------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded keystore file |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias (kerjaflow) |
| `ANDROID_KEY_PASSWORD` | Key password |

### Encoding Keystore for CI/CD

```bash
# Encode keystore to base64
base64 -i release.keystore -o release.keystore.base64

# Copy content to GitHub secret ANDROID_KEYSTORE_BASE64
cat release.keystore.base64
```

### Decoding in CI/CD Workflow

```yaml
- name: Decode keystore
  run: |
    echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/keystore/release.keystore
    echo "storePassword=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}" >> android/key.properties
    echo "keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}" >> android/key.properties
    echo "keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}" >> android/key.properties
    echo "storeFile=keystore/release.keystore" >> android/key.properties
```

## Upload Key for Google Play App Signing

Google Play App Signing provides additional security by managing your app signing key. To enroll:

1. Go to Google Play Console > Your App > Release > Setup > App signing
2. Choose "Export and upload a key from Java keystore"
3. Follow the instructions to upload your upload key

### Generate Upload Key (if using Google Play App Signing)

```bash
keytool -genkey -v \
  -keystore upload.keystore \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass <UPLOAD_STORE_PASSWORD> \
  -keypass <UPLOAD_KEY_PASSWORD> \
  -dname "CN=KerjaFlow Upload, OU=Mobile, O=KerjaFlow Sdn Bhd, L=Kuala Lumpur, ST=WP, C=MY"
```

## Huawei AppGallery Signing

Huawei requires a separate signing configuration:

1. Go to Huawei AppGallery Connect
2. Navigate to My Apps > Your App > App Information
3. Download the `agconnect-services.json` file
4. Configure signing in AppGallery Connect

## Security Best Practices

1. **Never commit** keystore files or passwords to version control
2. **Use strong passwords** (minimum 16 characters, mixed case, numbers, symbols)
3. **Backup keystore** securely (encrypted cloud storage, hardware security module)
4. **Limit access** to keystore credentials (need-to-know basis)
5. **Rotate keys** periodically if supported by the platform
6. **Enable 2FA** on Google Play Console and Huawei AppGallery Connect

## SHA-256 Fingerprints

To get SHA-256 fingerprints for Firebase, Google APIs, etc.:

```bash
# Debug fingerprint
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android

# Release fingerprint
keytool -list -v -keystore release.keystore -alias kerjaflow
```

## Troubleshooting

### "Keystore was tampered with, or password was incorrect"
- Verify the password is correct
- Check if the keystore file is corrupted
- Regenerate keystore if necessary

### "No key with alias found in keystore"
- Verify the alias name matches exactly (case-sensitive)
- List all aliases: `keytool -list -keystore release.keystore`

### APK signature verification failed
- Ensure you're using the correct keystore for the variant
- Check if ProGuard/R8 is stripping necessary classes
