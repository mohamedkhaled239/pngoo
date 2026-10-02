# iOS release checklist

The project contains an App Store Codemagic workflow in `codemagic.yaml` and
uses the iOS bundle identifier `com.tolba.videoDownloudApp`. If the App Store
record uses another identifier, update it consistently in Xcode, Firebase, and
`codemagic.yaml` before building.

## Apple Developer

1. Create an explicit App ID matching the bundle identifier.
2. Enable **Push Notifications** and **Background Modes / Remote notifications**.
3. Regenerate the App Store provisioning profile after enabling Push.
4. Create an APNs authentication key (`.p8`) and save its Key ID and Team ID.
5. Do not reuse an older provisioning profile created before Push was enabled.

## Firebase

The Apple app is already registered in Firebase as
`1:234949198999:ios:e198457c0a9209975d15d2`, with bundle ID
`com.tolba.videoDownloudApp`. Its generated `GoogleService-Info.plist` is
included in the Runner target.

1. Open Project settings > Cloud Messaging.
2. Under the Tolba iOS app, upload the APNs `.p8` key.
3. Enter the APNs Key ID and Apple Team ID.
4. Confirm that the Firebase iOS app bundle ID exactly matches the App Store ID.
5. Keep Firebase method swizzling enabled; the project does not disable it.

## Codemagic

1. Upload or fetch an Apple Distribution certificate and an App Store
   provisioning profile that includes the Push Notifications entitlement.
2. Create an environment-variable group named `appstore_credentials`.
3. Add these secret variables to the group:
   - `APP_STORE_CONNECT_PRIVATE_KEY`
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`
   - `APP_STORE_CONNECT_ISSUER_ID`
4. Run the `iOS App Store` workflow. A successful run produces an IPA and
   submits it to TestFlight.
5. The workflow verifies that the signed archive contains
   `aps-environment=production`; it intentionally fails if the selected profile
   cannot receive production APNs notifications.

## AdMob

1. The production iOS app ID is configured in `ios/Runner/Info.plist`.
2. Publish the required consent message from AdMob > Privacy & messaging.
3. Verify all four iOS ad units are active in the same AdMob app.
4. New ad units can return **No fill** for a while; this is not an SDK failure.

## Notification verification

Install the TestFlight build on a physical iPhone, accept notification
permission, copy its FCM token from the app settings, then use Firebase
Messaging's **Send test message** while the app is in the background.
