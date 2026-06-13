# Push Notifications

> APNs setup, permission request best practices, remote and rich notifications, silent push for background sync, and FCM vs APNs comparison.

## Table of Contents

- [1. APNs Setup](#1-apns-setup)
- [2. Permission Request Flow](#2-permission-request-flow)
- [3. Remote Notifications](#3-remote-notifications)
- [4. Rich Notifications](#4-rich-notifications)
- [5. Silent Push](#5-silent-push)
- [6. FCM vs APNs Direct](#6-fcm-vs-apns-direct)

---

## 1. APNs Setup

### 1.1 Certificates and Keys

**Recommended: APNs Auth Key (p8)** -- one key works for all apps in your team, does not expire.

1. Apple Developer Portal > Keys > Create Key
2. Enable "Apple Push Notifications service (APNs)"
3. Download the `.p8` file (one-time download)
4. Note the Key ID and Team ID

**Legacy: APNs Certificate (p12)** -- per-app, expires yearly. Avoid for new projects.

### 1.2 Entitlements

In Xcode: Signing & Capabilities > + Capability > Push Notifications.

This adds to your entitlements file:

```xml
<key>aps-environment</key>
<string>development</string>  <!-- or "production" for release -->
```

### 1.3 App Delegate Registration

```swift
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs token: \(token)")
        // Send token to your server
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("APNs registration failed: \(error)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Called when notification arrives while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]
    }

    // Called when user taps notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        handleNotificationTap(userInfo: userInfo)
    }
}
```

---

## 2. Permission Request Flow

### 2.1 Best Practices for Timing

**Do not** request permission on first launch. Instead:

```
App Launch
    |
    v
Onboarding (no push ask)
    |
    v
User performs relevant action
(e.g., creates a reminder, follows a topic)
    |
    v
Pre-permission screen (explain value)
    |
    v
System prompt (UNUserNotificationCenter)
```

### 2.2 Implementation

```swift
import UserNotifications

struct NotificationPermission {
    static func requestIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(
                    options: [.alert, .badge, .sound]
                )
                if granted {
                    await MainActor.run {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                return granted
            } catch {
                return false
            }
        case .authorized, .provisional:
            return true
        case .denied, .ephemeral:
            return false
        @unknown default:
            return false
        }
    }

    /// Provisional authorization: delivers quietly to Notification Center
    /// without interrupting the user. Good for first-time engagement.
    static func requestProvisional() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(
                options: [.alert, .badge, .sound, .provisional]
            )
        } catch {
            return false
        }
    }
}
```

### 2.3 Pre-Permission Screen Pattern

```swift
struct PushPrePermissionView: View {
    let onAllow: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            Text("Stay in the Loop")
                .font(.title2.bold())

            Text("Get notified when your tasks are due, when collaborators comment, and when important updates happen.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Enable Notifications", action: onAllow)
                .buttonStyle(.borderedProminent)

            Button("Maybe Later", action: onSkip)
                .foregroundStyle(.secondary)
        }
        .padding(32)
    }
}
```

---

## 3. Remote Notifications

### 3.1 APNs Payload

```json
{
    "aps": {
        "alert": {
            "title": "New Message",
            "subtitle": "From Alice",
            "body": "Hey, are you free for lunch?"
        },
        "badge": 3,
        "sound": "default",
        "thread-id": "chat-alice",
        "category": "MESSAGE"
    },
    "chatId": "abc123",
    "senderId": "user-456"
}
```

### 3.2 Server-Side Send (Node.js with apn)

```javascript
const apn = require("@parse/node-apn");

const provider = new apn.Provider({
    token: {
        key: "./AuthKey_XXXXXXXXXX.p8",
        keyId: "XXXXXXXXXX",
        teamId: "YYYYYYYYYY",
    },
    production: false,
});

const notification = new apn.Notification();
notification.alert = { title: "New Message", body: "Hey there!" };
notification.badge = 1;
notification.topic = "com.example.myapp";
notification.payload = { chatId: "abc123" };

await provider.send(notification, deviceToken);
```

---

## 4. Rich Notifications

### 4.1 Notification Service Extension

File > New > Target > Notification Service Extension.

```swift
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler handler: @escaping (UNNotificationContent) -> Void
    ) {
        guard let content = request.content.mutableCopy() as? UNMutableNotificationContent,
              let imageURLString = content.userInfo["imageURL"] as? String,
              let imageURL = URL(string: imageURLString) else {
            handler(request.content)
            return
        }

        // Download and attach image
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: imageURL)
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + ".jpg")
                try data.write(to: tempURL)

                let attachment = try UNNotificationAttachment(
                    identifier: "image",
                    url: tempURL
                )
                content.attachments = [attachment]
                handler(content)
            } catch {
                handler(content)
            }
        }
    }
}
```

### 4.2 Actionable Notifications

```swift
// Register categories at launch
func registerCategories() {
    let reply = UNTextInputNotificationAction(
        identifier: "REPLY",
        title: "Reply",
        textInputButtonTitle: "Send",
        textInputPlaceholder: "Type a reply..."
    )
    let markRead = UNNotificationAction(
        identifier: "MARK_READ",
        title: "Mark as Read"
    )

    let messageCategory = UNNotificationCategory(
        identifier: "MESSAGE",
        actions: [reply, markRead],
        intentIdentifiers: []
    )

    UNUserNotificationCenter.current().setNotificationCategories([messageCategory])
}
```

---

## 5. Silent Push

### 5.1 Background Sync Trigger

Silent push wakes your app in the background to fetch new data. No user-visible alert.

**Payload:**

```json
{
    "aps": {
        "content-available": 1
    },
    "syncType": "new-content"
}
```

**Handler:**

```swift
func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any]
) async -> UIBackgroundFetchResult {
    guard let syncType = userInfo["syncType"] as? String else {
        return .noData
    }

    do {
        let hasNew = try await DataSyncService.shared.sync(type: syncType)
        return hasNew ? .newData : .noData
    } catch {
        return .failed
    }
}
```

**Requirements:**
- Enable Background Modes > Remote notifications in Xcode capabilities
- System throttles silent push -- do not rely on guaranteed delivery
- You get ~30 seconds of background execution time

---

## 6. FCM vs APNs Direct

| Criteria | APNs Direct | Firebase Cloud Messaging |
|----------|-------------|--------------------------|
| **Setup** | p8 key, custom server | Firebase SDK + console |
| **Cross-platform** | iOS/macOS only | iOS, Android, Web |
| **Topics** | Manual server logic | Built-in topic subscribe |
| **Analytics** | Manual | Built-in delivery metrics |
| **Dependency** | None (first-party) | Google Firebase SDK |
| **Payload limit** | 4 KB | 4 KB (wraps APNs) |
| **Cost** | Free | Free |
| **Latency** | Direct to Apple | FCM -> APNs (small overhead) |

**Recommendation:**
- **Single-platform iOS app** -- use APNs directly, fewer dependencies
- **Cross-platform app** -- use FCM for unified server-side API
- **Either way**, the device token registration and permission flow are identical on the client side

---

*Version: 0.1.0*
*Last updated: 2026-05-12*
