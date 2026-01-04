# iPhone Development Workflow

Complete guide for building and deploying pixelboop to a physical iPhone using terminal commands.

## Table of Contents
- [One-Time Setup](#one-time-setup)
- [Daily Development Workflow](#daily-development-workflow)
- [Common Issues & Solutions](#common-issues--solutions)
- [Command Reference](#command-reference)

---

## One-Time Setup

### 1. Add Apple ID to Xcode

**Only needed once per development machine.**

```bash
# Open Xcode Settings
# Xcode → Settings (⌘,) → Accounts → Click '+' → Add Apple ID
```

Or manually:
1. Open Xcode
2. Go to **Settings** (⌘,)
3. Click **Accounts** tab
4. Click **+** button
5. Select **Apple ID**
6. Sign in with your Apple ID

This creates your personal development team and signing certificates.

### 2. Configure Project Signing

**Already done for pixelboop, but documented for reference:**

The project is configured with:
- **Development Team**: `L8JYAN7WBK` (personal team)
- **Bundle Identifier**: `audiolux.pixelboop`
- **Automatic Signing**: Enabled

Location: `pixelboop.xcodeproj/project.pbxproj`

```xml
DEVELOPMENT_TEAM = L8JYAN7WBK;
CODE_SIGN_STYLE = Automatic;
```

### 3. Enable Developer Mode on iPhone

**Required for iOS 16+ devices.**

#### First Build Attempt
When you first try to build to the device, Xcode will prompt iPhone to enable Developer Mode.

#### Manual Activation
1. On iPhone: **Settings → Privacy & Security**
2. Scroll to bottom → **Developer Mode**
3. Toggle **ON**
4. iPhone will restart
5. After restart, confirm Developer Mode

**Note**: Developer Mode option only appears after the first build attempt from Xcode.

### 4. Trust Developer Certificate on iPhone

**After first successful build.**

1. On iPhone: **Settings → General → VPN & Device Management**
2. Under **Developer App**, tap your Apple ID email
3. Tap **Trust "[your email]"**
4. Confirm **Trust**

If you see "device management settings do not allow":
- Check **Settings → Screen Time → Content & Privacy Restrictions**
- Ensure **Installing Apps** is set to **Allow**

---

## Daily Development Workflow

### Quick Reference

```bash
# 1. Make code changes
# 2. Build for device
xcodebuild -project pixelboop.xcodeproj \
  -scheme pixelboop \
  -configuration Debug \
  -destination 'id=00008130-00040D9C1A41001C' \
  -allowProvisioningUpdates \
  build

# 3. Install on device
xcrun devicectl device install app \
  --device 00008130-00040D9C1A41001C \
  /Users/dbi/Library/Developer/Xcode/DerivedData/pixelboop-*/Build/Products/Debug-iphoneos/pixelboop.app

# 4. Test on iPhone
```

### Detailed Workflow

#### 1. Connect iPhone
- Connect iPhone to Mac via USB
- Unlock iPhone
- If prompted, tap **Trust This Computer** on iPhone

#### 2. Verify Device Connection
```bash
# List connected devices
xcrun xctrace list devices

# Should show:
# MDB iPhone (18.6.2) - Connected (00008130-00040D9C1A41001C)
```

#### 3. Build the App
```bash
xcodebuild -project /Users/dbi/Documents/GitHub/pixelboop/pixelboop.xcodeproj \
  -scheme pixelboop \
  -configuration Debug \
  -destination 'id=00008130-00040D9C1A41001C' \
  -allowProvisioningUpdates \
  build 2>&1 | tail -20
```

**Build Time**: ~30-60 seconds

**Success Output**:
```
** BUILD SUCCEEDED **
```

**Common Flags**:
- `-allowProvisioningUpdates`: Auto-handles signing profiles
- `-configuration Debug`: Development build (faster, includes debug symbols)
- `2>&1 | tail -20`: Show last 20 lines (cleaner output)

#### 4. Install on Device
```bash
xcrun devicectl device install app \
  --device 00008130-00040D9C1A41001C \
  /Users/dbi/Library/Developer/Xcode/DerivedData/pixelboop-cnihwbnjpnrcymglhztlhiaoujdw/Build/Products/Debug-iphoneos/pixelboop.app
```

**Install Time**: ~5-10 seconds

**Success Output**:
```
App installed:
• bundleID: audiolux.pixelboop
• installationURL: file:///private/var/containers/Bundle/Application/[UUID]/pixelboop.app/
```

**Note**: The DerivedData path includes a unique hash (`pixelboop-cnihwbnjpnrcymglhztlhiaoujdw`) that persists per project.

#### 5. Launch App Manually
The app is installed but not auto-launched. Tap the pixelboop icon on your iPhone home screen.

### Iterative Development

For rapid iteration:

```bash
# Make changes → build → install → test
# Repeat as needed

# Optional: Create an alias
alias deploy-pixelboop='xcodebuild -project ~/Documents/GitHub/pixelboop/pixelboop.xcodeproj -scheme pixelboop -configuration Debug -destination "id=00008130-00040D9C1A41001C" -allowProvisioningUpdates build && xcrun devicectl device install app --device 00008130-00040D9C1A41001C ~/Library/Developer/Xcode/DerivedData/pixelboop-*/Build/Products/Debug-iphoneos/pixelboop.app'
```

---

## Common Issues & Solutions

### Issue: "Signing requires a development team"

**Error**:
```
error: Signing for "pixelboop" requires a development team.
```

**Solution**:
Ensure `DEVELOPMENT_TEAM` is set in project file:
```bash
grep -A5 "DEVELOPMENT_TEAM" pixelboop.xcodeproj/project.pbxproj
```

Should show:
```
DEVELOPMENT_TEAM = L8JYAN7WBK;
```

If missing, add it to both Debug and Release configurations.

### Issue: "Developer Mode is disabled"

**Error**:
```
Developer mode is not currently enabled
```

**Solution**:
1. On iPhone: **Settings → Privacy & Security → Developer Mode**
2. Toggle ON
3. Restart iPhone
4. Confirm after restart

### Issue: "Unable to launch" - Invalid signature

**Error**:
```
The request was denied... inadequate entitlements or its profile has not been explicitly trusted
```

**Solution**:
Trust the developer certificate:
1. iPhone: **Settings → General → VPN & Device Management**
2. Tap your developer profile
3. Tap **Trust**

### Issue: App not visible on iPhone

**Possible Causes**:
1. Install succeeded but app in different screen/folder
2. Trust certificate not completed

**Solution**:
1. Search for "pixelboop" in iPhone Spotlight
2. Check all home screens
3. Verify trust certificate (above)

### Issue: Build succeeds but install fails

**Error**:
```
The application failed to launch
```

**Solution**:
1. Unlock iPhone
2. Check USB connection
3. Re-trust computer if prompted
4. Try installing again

### Issue: Device not found

**Error**:
```
xcodebuild: error: Unable to find a destination matching the provided destination specifier
```

**Solution**:
```bash
# List devices to get correct ID
xcrun xctrace list devices

# Use the exact device ID shown
```

---

## Command Reference

### Device Management

```bash
# List all devices (simulators and physical)
xcrun xctrace list devices

# List only physical devices
xcrun xctrace list devices | grep -v Simulator

# Get device details
xcrun devicectl list devices
```

### Build Commands

```bash
# Debug build (faster, includes debug info)
xcodebuild -project pixelboop.xcodeproj \
  -scheme pixelboop \
  -configuration Debug \
  -destination 'id=DEVICE_ID' \
  build

# Release build (optimized, smaller binary)
xcodebuild -project pixelboop.xcodeproj \
  -scheme pixelboop \
  -configuration Release \
  -destination 'id=DEVICE_ID' \
  build

# Clean build
xcodebuild clean -project pixelboop.xcodeproj -scheme pixelboop

# Show build settings
xcodebuild -project pixelboop.xcodeproj \
  -scheme pixelboop \
  -showBuildSettings
```

### Installation Commands

```bash
# Install app
xcrun devicectl device install app \
  --device DEVICE_ID \
  /path/to/app.app

# Launch app (if supported)
xcrun devicectl device process launch \
  --device DEVICE_ID \
  BUNDLE_ID

# Uninstall app
xcrun devicectl device uninstall app \
  --device DEVICE_ID \
  BUNDLE_ID
```

### Debugging

```bash
# View device logs
xcrun devicectl device info logs --device DEVICE_ID

# Check provisioning profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# View signing identity
security find-identity -v -p codesigning
```

---

## Project-Specific Configuration

### Device Information
- **Device**: MDB iPhone (iPhone model)
- **iOS Version**: 18.6.2
- **Device ID**: `00008130-00040D9C1A41001C`

### Project Settings
- **Project**: `pixelboop.xcodeproj`
- **Scheme**: `pixelboop`
- **Bundle ID**: `audiolux.pixelboop`
- **Team ID**: `L8JYAN7WBK`
- **DerivedData Path**: `/Users/dbi/Library/Developer/Xcode/DerivedData/pixelboop-cnihwbnjpnrcymglhztlhiaoujdw/`

### Build Artifacts
- **App Location**: `DerivedData/pixelboop-*/Build/Products/Debug-iphoneos/pixelboop.app`
- **Build Time**: ~30-60 seconds
- **App Size**: ~2-5 MB (Debug build)

---

## Tips & Best Practices

### Performance
1. **Incremental Builds**: Only changed files are recompiled
2. **DerivedData**: Persists between builds for faster compilation
3. **Parallel Builds**: Xcode automatically uses multiple cores

### Development Cycle
1. Make small, testable changes
2. Build and install frequently
3. Test on device immediately
4. Commit working changes

### Troubleshooting Strategy
1. Check build output for errors
2. Verify device connection
3. Ensure Developer Mode enabled
4. Confirm certificate trust
5. Try clean build if issues persist

### Git Workflow Integration
```bash
# Make changes
# Test on device
git add .
git commit -m "Description"
git push
```

The current workflow we've established:
1. Claude makes code changes
2. Build with xcodebuild
3. Install with devicectl
4. Test on iPhone
5. Commit and push if successful

---

## Additional Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [xcodebuild Manual](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [Device Management with devicectl](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)

---

**Last Updated**: 2026-01-03
**Maintained By**: Development Team
