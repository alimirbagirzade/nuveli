# Google Sign-In — One-Time Setup

The code for Google Sign-In is wired up in `lib/features/auth/services/google_signin_service.dart`, but it can only work after the OAuth clients are registered out-of-band. The dashboard steps below are a one-time investment per environment (dev + prod).

Total time: ~20 minutes the first time, ~5 minutes for prod after dev is done.

---

## 1. Google Cloud / Firebase Console

Firebase Console is the easier path because it auto-creates the OAuth clients and writes them into `google-services.json` / `GoogleService-Info.plist` for you.

Open [https://console.firebase.google.com](https://console.firebase.google.com) → your Nuveli project.

### Enable Google as a sign-in method
1. Authentication → Sign-in method → **Add new provider** → **Google**
2. Toggle **Enable**
3. Set the **public-facing project name** (shown on Google's consent screen) to `Nuveli`
4. Set the **project support email** to `support@nuveli.com.tr`
5. **Save**

This step automatically registers two OAuth client IDs in Google Cloud:
- Web client (used by Supabase to verify tokens) — copy the **client ID** and **client secret**, you'll need them in step 3
- iOS client (used by `google_sign_in` package on device)

### Verify the iOS client has a reversed-client-id
1. Project settings → **General** → **Your apps** → iOS app
2. Download the latest **`GoogleService-Info.plist`** if it doesn't already include `REVERSED_CLIENT_ID`
3. Drop it into `app/ios/Runner/` (overwriting the existing one if needed) and re-add it to the Xcode target

### Verify Android SHA fingerprints
1. Project settings → General → Your apps → Android app → **SHA certificate fingerprints**
2. Add both:
   - **Debug SHA-1**: get with `cd app/android && ./gradlew signingReport | grep SHA1` (the one under `debug` config)
   - **Play App Signing SHA-1 + SHA-256**: Play Console → App integrity → App signing → copy both
3. Re-download `google-services.json` and drop it into `app/android/app/`

---

## 2. iOS — Info.plist URL Scheme

The `google_sign_in` package on iOS opens an in-app browser that comes back via a custom URL scheme. iOS needs to know which scheme the app handles.

In `app/ios/Runner/Info.plist`, find the existing `CFBundleURLTypes` array and add a second `<dict>` next to the `nuveli` scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.nuveli.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>nuveli</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <!--
              Paste REVERSED_CLIENT_ID from GoogleService-Info.plist here.
              It looks like com.googleusercontent.apps.123-abc.
            -->
            <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

(Optional, but recommended: also add `<key>GIDClientID</key>` with the iOS client ID. The `google_sign_in` package picks it up from `GoogleService-Info.plist` if present, so this is belt-and-braces.)

---

## 3. Supabase — Google OAuth Provider

In [Supabase Dashboard](https://app.supabase.com) → your project → **Authentication** → **Providers** → **Google**:

1. **Enable Google provider**
2. Paste the **Web client ID** (NOT the iOS or Android client ID) from step 1 into **Authorized Client IDs**
3. Paste the **Web client secret** into **Client Secret** (only needed if you ever use the OAuth redirect flow on web; harmless to include)
4. **Save**

That's it. Supabase will now accept ID tokens signed by Google for that web client.

---

## 4. Smoke Test

```bash
cd app
flutter run -d <ios-device>   # or -d <android-device>
```

On the Welcome/Login/Signup screen:
- Tap "Continue with Google"
- Pick an account in the system picker
- App lands on the dashboard, logged in as the picked account

If you see "Google Sign-In failed" instead, the most common causes are:
- iOS: missing or wrong `REVERSED_CLIENT_ID` URL scheme
- Android: SHA-1 not registered in Firebase, or wrong `google-services.json`
- Supabase: web client ID not pasted into the Google provider, or the wrong client ID was pasted

---

## 5. Reference

- Package: [`google_sign_in` ^6.2.1](https://pub.dev/packages/google_sign_in/versions/6.2.1)
- Supabase: [Sign in with Google docs](https://supabase.com/docs/guides/auth/social-login/auth-google)
- Apple Sign-In setup (already done) lives in `lib/features/auth/services/apple_signin_service.dart`
