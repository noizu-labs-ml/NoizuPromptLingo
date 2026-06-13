# Live Activities

> ActivityKit setup, starting/updating/ending activities, Dynamic Island compact and expanded views, Lock Screen presentation, and push-to-update via APNs.

## Table of Contents

- [1. ActivityKit Setup](#1-activitykit-setup)
- [2. Starting, Updating, and Ending](#2-starting-updating-and-ending)
- [3. Dynamic Island Views](#3-dynamic-island-views)
- [4. Lock Screen Presentation](#4-lock-screen-presentation)
- [5. Push-to-Update via APNs](#5-push-to-update-via-apns)

---

## 1. ActivityKit Setup

### 1.1 Capabilities

1. Xcode > main app target > Signing & Capabilities > + Capability
2. Add "Push Notifications" (if using push updates)
3. In `Info.plist`, add `NSSupportsLiveActivities = YES`

### 1.2 Attributes Definition

Attributes define the static and dynamic parts of your Live Activity.

```swift
import ActivityKit

struct OrderAttributes: ActivityAttributes {
    // Static data -- set once when activity starts
    let orderNumber: String
    let restaurantName: String

    // Dynamic data -- changes over time
    struct ContentState: Codable, Hashable {
        let status: OrderStatus
        let estimatedMinutes: Int
        let driverName: String?
    }
}

enum OrderStatus: String, Codable, Hashable {
    case confirmed
    case preparing
    case readyForPickup
    case enRoute
    case delivered

    var label: String {
        switch self {
        case .confirmed: return "Confirmed"
        case .preparing: return "Preparing"
        case .readyForPickup: return "Ready"
        case .enRoute: return "On the way"
        case .delivered: return "Delivered"
        }
    }

    var icon: String {
        switch self {
        case .confirmed: return "checkmark.circle"
        case .preparing: return "flame"
        case .readyForPickup: return "bag"
        case .enRoute: return "car"
        case .delivered: return "house"
        }
    }
}
```

### 1.3 Widget Bundle

Live Activity UI lives inside a Widget Extension target. Add to your widget bundle:

```swift
import WidgetKit
import SwiftUI

@main
struct MyWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Regular widgets
        TaskWidget()

        // Live Activity
        OrderLiveActivity()
    }
}
```

---

## 2. Starting, Updating, and Ending

### 2.1 Starting an Activity

```swift
import ActivityKit

class OrderActivityManager {
    private var currentActivity: Activity<OrderAttributes>?

    func startTracking(orderNumber: String, restaurant: String) throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw ActivityError.notSupported
        }

        let attributes = OrderAttributes(
            orderNumber: orderNumber,
            restaurantName: restaurant
        )
        let initialState = OrderAttributes.ContentState(
            status: .confirmed,
            estimatedMinutes: 30,
            driverName: nil
        )
        let content = ActivityContent(
            state: initialState,
            staleDate: Calendar.current.date(byAdding: .minute, value: 45, to: .now)
        )

        currentActivity = try Activity.request(
            attributes: attributes,
            content: content,
            pushType: .token  // Enable push updates; use nil for local-only
        )

        // If using push updates, send the token to your server
        if let activity = currentActivity {
            Task {
                for await tokenData in activity.pushTokenUpdates {
                    let token = tokenData.map { String(format: "%02x", $0) }.joined()
                    await sendTokenToServer(token, orderNumber: orderNumber)
                }
            }
        }
    }

    func sendTokenToServer(_ token: String, orderNumber: String) async {
        // POST token to your backend for push-to-update
    }
}
```

### 2.2 Updating an Activity

```swift
extension OrderActivityManager {
    func updateStatus(_ status: OrderStatus, eta: Int, driver: String? = nil) async {
        guard let activity = currentActivity else { return }

        let updatedState = OrderAttributes.ContentState(
            status: status,
            estimatedMinutes: eta,
            driverName: driver
        )
        let content = ActivityContent(
            state: updatedState,
            staleDate: Calendar.current.date(byAdding: .minute, value: eta + 15, to: .now)
        )

        await activity.update(content)
    }
}
```

### 2.3 Ending an Activity

```swift
extension OrderActivityManager {
    func endActivity(finalStatus: OrderStatus) async {
        guard let activity = currentActivity else { return }

        let finalState = OrderAttributes.ContentState(
            status: finalStatus,
            estimatedMinutes: 0,
            driverName: nil
        )
        let content = ActivityContent(
            state: finalState,
            staleDate: nil
        )

        // dismissalPolicy: .immediate removes right away
        // .default keeps on Lock Screen for up to 4 hours
        // .after(_:) removes after a specific date
        await activity.end(content, dismissalPolicy: .default)
        currentActivity = nil
    }
}
```

---

## 3. Dynamic Island Views

### 3.1 Full Live Activity Widget

```swift
import WidgetKit
import SwiftUI

struct OrderLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderAttributes.self) { context in
            // Lock Screen / banner presentation
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded regions
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.state.status.label, systemImage: context.state.status.icon)
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.estimatedMinutes) min")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: progress(for: context.state.status))
                        .tint(.blue)
                    HStack {
                        Text("Order #\(context.attributes.orderNumber)")
                        Spacer()
                        if let driver = context.state.driverName {
                            Text(driver)
                        }
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            } compactLeading: {
                // Minimal leading (left of TrueDepth camera)
                Image(systemName: context.state.status.icon)
                    .foregroundStyle(.blue)
            } compactTrailing: {
                // Minimal trailing (right of TrueDepth camera)
                Text("\(context.state.estimatedMinutes)m")
                    .font(.caption2.bold())
            } minimal: {
                // When multiple activities compete, only one icon
                Image(systemName: "bag")
                    .foregroundStyle(.blue)
            }
        }
    }

    func progress(for status: OrderStatus) -> Double {
        switch status {
        case .confirmed: return 0.1
        case .preparing: return 0.3
        case .readyForPickup: return 0.5
        case .enRoute: return 0.75
        case .delivered: return 1.0
        }
    }
}
```

### 3.2 Dynamic Island Sizing

| Region | Purpose | Constraints |
|--------|---------|-------------|
| `compactLeading` | Left of camera notch | Small icon or short text |
| `compactTrailing` | Right of camera notch | Short text or number |
| `minimal` | Shared space with other activities | Single icon |
| Expanded `.leading` | Left column | Labels, icons |
| Expanded `.trailing` | Right column | Values, badges |
| Expanded `.center` | Full width below camera | Graphs, maps |
| Expanded `.bottom` | Bottom region | Progress bars, details |

---

## 4. Lock Screen Presentation

```swift
struct LockScreenView: View {
    let context: ActivityViewContext<OrderAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(context.attributes.restaurantName)
                        .font(.headline)
                    Text("Order #\(context.attributes.orderNumber)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(context.state.estimatedMinutes) min")
                    .font(.title2.bold())
                    .foregroundStyle(.blue)
            }

            // Status progress
            HStack(spacing: 4) {
                ForEach(OrderStatus.allSteps, id: \.self) { step in
                    Capsule()
                        .fill(step <= context.state.status ? Color.blue : Color.secondary.opacity(0.3))
                        .frame(height: 4)
                }
            }

            HStack {
                Label(context.state.status.label, systemImage: context.state.status.icon)
                Spacer()
                if let driver = context.state.driverName {
                    Label(driver, systemImage: "person.circle")
                }
            }
            .font(.caption)
        }
        .padding()
        .activityBackgroundTint(.black.opacity(0.8))
        .activitySystemActionForegroundColor(.white)
    }
}

extension OrderStatus {
    static let allSteps: [OrderStatus] = [.confirmed, .preparing, .readyForPickup, .enRoute, .delivered]

    static func <= (lhs: OrderStatus, rhs: OrderStatus) -> Bool {
        let order: [OrderStatus] = allSteps
        guard let l = order.firstIndex(of: lhs), let r = order.firstIndex(of: rhs) else { return false }
        return l <= r
    }
}
```

---

## 5. Push-to-Update via APNs

### 5.1 APNs Payload Format

Live Activity push updates use a special APNs topic and content-state payload:

```json
{
    "aps": {
        "timestamp": 1234567890,
        "event": "update",
        "content-state": {
            "status": "enRoute",
            "estimatedMinutes": 12,
            "driverName": "Alex"
        },
        "alert": {
            "title": "Order Update",
            "body": "Your order is on the way!"
        }
    }
}
```

**To end via push:**

```json
{
    "aps": {
        "timestamp": 1234567890,
        "event": "end",
        "dismissal-date": 1234571490,
        "content-state": {
            "status": "delivered",
            "estimatedMinutes": 0,
            "driverName": "Alex"
        }
    }
}
```

### 5.2 APNs Headers

| Header | Value |
|--------|-------|
| `apns-topic` | `{bundle-id}.push-type.liveactivity` |
| `apns-push-type` | `liveactivity` |
| `apns-priority` | `10` (immediate) or `5` (power-friendly) |

### 5.3 Server-Side Send (Node.js)

```javascript
const http2 = require("http2");
const jwt = require("jsonwebtoken");

async function updateLiveActivity(deviceToken, contentState) {
    const token = generateAPNsJWT(); // your p8-based JWT

    const client = http2.connect("https://api.push.apple.com");
    const headers = {
        ":method": "POST",
        ":path": `/3/device/${deviceToken}`,
        "authorization": `bearer ${token}`,
        "apns-topic": "com.example.myapp.push-type.liveactivity",
        "apns-push-type": "liveactivity",
        "apns-priority": "10",
    };

    const payload = JSON.stringify({
        aps: {
            timestamp: Math.floor(Date.now() / 1000),
            event: "update",
            "content-state": contentState,
        },
    });

    const req = client.request(headers);
    req.write(payload);
    req.end();
}
```

### 5.4 Budget and Limits

| Constraint | Limit |
|------------|-------|
| Push updates per hour | ~Frequent (Apple dynamically manages) |
| Max active Live Activities per app | 5 |
| Max duration | 8 hours active + 4 hours on Lock Screen after end |
| Stale date | System dims the activity if no update by this time |
| Content-state size | 4 KB max |

---

*Version: 0.1.0*
*Last updated: 2026-05-12*
