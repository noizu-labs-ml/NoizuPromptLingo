# In-App Purchases

> StoreKit 2 async/await API, product types, purchase flow, receipt validation, subscription management UI, and testing strategies.

## Table of Contents

- [1. StoreKit 2 Fundamentals](#1-storekit-2-fundamentals)
- [2. Product Types](#2-product-types)
- [3. Purchase Flow](#3-purchase-flow)
- [4. Receipt Validation](#4-receipt-validation)
- [5. Subscription Management](#5-subscription-management)
- [6. Testing](#6-testing)

---

## 1. StoreKit 2 Fundamentals

### 1.1 Product Configuration

Define products in App Store Connect or in a local StoreKit Configuration file for testing.

```swift
import StoreKit

@Observable
class StoreManager {
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private var transactionListener: Task<Void, Error>?

    static let productIDs: Set<String> = [
        "com.example.pro.monthly",
        "com.example.pro.yearly",
        "com.example.premium.lifetime",
        "com.example.gems.100"
    ]

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
        Task { await updatePurchasedProducts() }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
    }
}
```

### 1.2 Transaction Listener

Always listen for transactions at app launch. This handles renewals, family sharing grants, refunds, and purchases completed outside your app (e.g., Ask to Buy).

```swift
extension StoreManager {
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await self.handleTransaction(transaction)
                await transaction.finish()
            }
        }
    }

    private func handleTransaction(_ transaction: Transaction) async {
        if transaction.revocationDate != nil {
            purchasedProductIDs.remove(transaction.productID)
        } else {
            purchasedProductIDs.insert(transaction.productID)
        }
    }

    func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchased.insert(transaction.productID)
            }
        }
        purchasedProductIDs = purchased
    }
}
```

---

## 2. Product Types

| Type | Behavior | Example |
|------|----------|---------|
| **Consumable** | Can buy multiple times, depleted by use | 100 gems, extra lives |
| **Non-consumable** | Buy once, permanent | Remove ads, lifetime pro |
| **Auto-renewable subscription** | Recurring billing until cancelled | Monthly pro plan |
| **Non-renewing subscription** | Fixed duration, no auto-renewal | 1-year access pass |

### 2.1 Identifying Product Type

```swift
func productTypeLabel(_ product: Product) -> String {
    switch product.type {
    case .consumable: return "Consumable"
    case .nonConsumable: return "Lifetime"
    case .autoRenewable: return "Subscription"
    case .nonRenewable: return "Pass"
    default: return "Unknown"
    }
}
```

---

## 3. Purchase Flow

### 3.1 Purchase Implementation

```swift
extension StoreManager {
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else {
                throw PurchaseError.verificationFailed
            }
            await handleTransaction(transaction)
            await transaction.finish()
            return transaction

        case .userCancelled:
            return nil

        case .pending:
            // Ask to Buy, or SCA pending
            return nil

        @unknown default:
            return nil
        }
    }
}

enum PurchaseError: LocalizedError {
    case verificationFailed
    var errorDescription: String? { "Purchase verification failed." }
}
```

### 3.2 Purchase UI

```swift
struct PaywallView: View {
    @Environment(StoreManager.self) private var store

    var body: some View {
        VStack(spacing: 16) {
            Text("Upgrade to Pro")
                .font(.title.bold())

            Text("Unlock all features and remove ads.")
                .foregroundStyle(.secondary)

            ForEach(store.products) { product in
                ProductCard(product: product)
            }

            Button("Restore Purchases") {
                Task { await store.updatePurchasedProducts() }
            }
            .font(.footnote)

            Text("Payment will be charged to your Apple ID. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ProductCard: View {
    let product: Product
    @Environment(StoreManager.self) private var store
    @State private var isPurchasing = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(product.displayName)
                    .font(.headline)
                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                Task {
                    isPurchasing = true
                    defer { isPurchasing = false }
                    _ = try? await store.purchase(product)
                }
            } label: {
                if isPurchasing {
                    ProgressView()
                } else {
                    Text(product.displayPrice)
                        .bold()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isPurchasing)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
```

---

## 4. Receipt Validation

### 4.1 On-Device (StoreKit 2)

StoreKit 2 JWS transactions are signed by Apple and verified locally by the framework. `Transaction.currentEntitlements` returns only verified transactions.

```swift
// StoreKit 2 handles verification automatically
for await result in Transaction.currentEntitlements {
    switch result {
    case .verified(let transaction):
        // Trusted -- signed and verified by StoreKit
        grantAccess(for: transaction.productID)
    case .unverified(_, let error):
        // Do not trust
        print("Unverified transaction: \(error)")
    }
}
```

### 4.2 Server-Side Validation

For high-value entitlements, validate on your server using the App Store Server API (v2):

```
POST https://api.storekit.itunes.apple.com/inApps/v1/transactions/{transactionId}
Authorization: Bearer <signed-jwt>
```

**When to use server-side:**
- Subscription-gated server content
- Cross-platform entitlements (iOS + web)
- Fraud-sensitive purchases
- Need to track churn and renewal metrics

### 4.3 App Store Server Notifications V2

Register a URL in App Store Connect to receive real-time subscription lifecycle events:

| Notification | Meaning |
|-------------|---------|
| `SUBSCRIBED` | New subscription or resubscribe |
| `DID_RENEW` | Successful renewal |
| `DID_FAIL_TO_RENEW` | Billing issue (grace period starts) |
| `EXPIRED` | Subscription ended |
| `REVOKE` | Refunded or family sharing revoked |
| `GRACE_PERIOD_EXPIRED` | Grace period ended, access should stop |

---

## 5. Subscription Management

### 5.1 Subscription Status

```swift
func checkSubscriptionStatus() async -> SubscriptionState {
    guard let statuses = try? await Product.SubscriptionInfo.status(
        for: "com.example.pro"  // subscription group ID
    ) else {
        return .notSubscribed
    }

    for status in statuses {
        guard case .verified(let renewal) = status.renewalInfo,
              case .verified(let transaction) = status.transaction else { continue }

        switch status.state {
        case .subscribed:
            return .active(expiresDate: transaction.expirationDate)
        case .inBillingRetryPeriod:
            return .billingIssue
        case .inGracePeriod:
            return .gracePeriod(expiresDate: transaction.expirationDate)
        case .expired:
            return .expired
        case .revoked:
            return .revoked
        default:
            continue
        }
    }
    return .notSubscribed
}
```

### 5.2 Manage Subscriptions Link

```swift
// Open the system subscription management sheet
Button("Manage Subscription") {
    Task {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        try? await AppStore.showManageSubscriptions(in: windowScene)
    }
}
```

---

## 6. Testing

### 6.1 StoreKit Testing in Xcode

1. File > New > File > StoreKit Configuration File
2. Add products matching your App Store Connect configuration
3. Edit Scheme > Run > Options > StoreKit Configuration > select your file

Benefits: No App Store Connect needed, instant transactions, controllable renewal periods, simulated failures.

### 6.2 Sandbox Testing

- Create sandbox tester accounts in App Store Connect > Users and Access > Sandbox
- Sign in on device: Settings > App Store > Sandbox Account
- Subscriptions renew at accelerated rates (monthly = 5 min, yearly = 1 hour)

### 6.3 Transaction Manager

Xcode > Debug > StoreKit > Manage Transactions -- lets you approve, refund, and inspect transactions during debugging.

### 6.4 Unit Testing Purchases

```swift
import XCTest
import StoreKitTest
@testable import MyApp

final class PurchaseTests: XCTestCase {
    var session: SKTestSession!
    var store: StoreManager!

    override func setUp() async throws {
        session = try SKTestSession(configurationFileNamed: "Products")
        session.disableDialogs = true
        session.clearTransactions()
        store = StoreManager()
        await store.loadProducts()
    }

    func testPurchaseLifetime() async throws {
        let product = store.products.first { $0.id == "com.example.premium.lifetime" }!
        let transaction = try await store.purchase(product)
        XCTAssertNotNil(transaction)
        XCTAssertTrue(store.purchasedProductIDs.contains("com.example.premium.lifetime"))
    }

    func testRestorePurchases() async throws {
        // Simulate a prior purchase
        try session.buyProduct(productIdentifier: "com.example.premium.lifetime")
        await store.updatePurchasedProducts()
        XCTAssertTrue(store.purchasedProductIDs.contains("com.example.premium.lifetime"))
    }
}
```

---

*Version: 0.1.0*
*Last updated: 2026-05-12*
