# 12. Sync System (Premium)

## Encryption Architecture

ClipStash sync uses end-to-end encryption. The server never has access to plaintext content.

## Key Derivation — Option A (Password-derived)

```mermaid
graph TD
    PW["User Password<br/>(never leaves device)"] --> KDF["Argon2id<br/>memory: 256MB<br/>iterations: 3<br/>parallelism: 4"]
    KDF --> MK["256-bit Master Key"]
    MK --> HKDF["HKDF-SHA256<br/>Key Expansion"]

    HKDF --> EK["Encryption Key<br/>AES-256-GCM<br/>(content encryption)"]
    HKDF --> AK["Auth Key<br/>HMAC-SHA256<br/>(server authentication)"]
    HKDF --> SK["Search Token Key<br/>(encrypted search tokens)"]

    AK --> SERVER["Server stores only:<br/>HMAC(Auth Key, challenge)<br/>⚠ Password unrecoverable"]

    style PW fill:#fbbf24,color:black
    style MK fill:#ef4444,color:white
    style EK fill:#22c55e,color:white
    style AK fill:#3b82f6,color:white
    style SK fill:#8b5cf6,color:white
    style SERVER fill:#64748b,color:white
```

## Key Derivation — Option B (Custom Keypair)

```mermaid
graph TD
    USER["User generates X25519<br/>keypair externally"] --> PUB["Public Key<br/>(registered with server)"]
    USER --> PRIV["Private Key<br/>(stored only on user devices)"]

    PRIV --> TRANSFER{"Manual Transfer<br/>Between Devices"}
    TRANSFER --> QR[QR Code]
    TRANSFER --> AD[AirDrop]
    TRANSFER --> USB[USB Drive]

    PUB --> SERVER["Sync Server"]
    PRIV --> DEC["Local Decryption<br/>on each device"]

    style PRIV fill:#ef4444,color:white
    style PUB fill:#22c55e,color:white
    style SERVER fill:#64748b,color:white
```

## Sync Protocol

```mermaid
sequenceDiagram
    participant D1 as Device A
    participant SS as Sync Server
    participant D2 as Device B

    Note over D1,D2: Sync on Copy
    D1->>D1: Copy event → new entry
    D1->>D1: Encrypt(entry, EncKey)<br/>→ ciphertext + nonce + tag
    D1->>D1: Pad ciphertext<br/>(hide entry size/type)
    D1->>SS: Upload encrypted blob<br/>+ vector clock
    SS->>SS: Store opaque blob<br/>(cannot read content)

    Note over D1,D2: Sync Pull
    D2->>SS: Poll for new entries<br/>(auth via HMAC challenge)
    SS-->>D2: Return encrypted blobs
    D2->>D2: Decrypt(blob, EncKey)<br/>→ plaintext entry
    D2->>D2: Index locally<br/>(FTS + vector)

    Note over D1,D2: Conflict Resolution
    D1->>SS: Update entry (clock: [A:3, B:1])
    D2->>SS: Update same entry (clock: [A:2, B:2])
    SS-->>D1: Conflict detected!
    SS-->>D2: Conflict detected!
    Note over D1,D2: User picks version<br/>or both preserved

    Note over D1,D2: Deletion Sync
    D1->>D1: Delete entry
    D1->>SS: Encrypted tombstone marker
    D2->>D2: Receive tombstone → remove entry
```

## Server-Side Guarantees

- Server stores only opaque ciphertext blobs.
- No server-side search capability (search is client-side only).
- Server cannot determine entry count, sizes, or types (padding applied).
- Audit log of sync events available to the user (encrypted).
- Open-source server component for self-hosting.

---

[← Menu Bar Interface](11-menu-bar-interface.md) | [Table of Contents](../product-spec.md#table-of-contents) | [Additional Features →](13-additional-features.md)

**Solution Analysis:** [Sandboxing](solution-analysis/07-sandboxing.md)
**User Stories:** [US-022](user-stories/US-022.md) · [US-023](user-stories/US-023.md) · [US-024](user-stories/US-024.md) · [US-025](user-stories/US-025.md) · [US-026](user-stories/US-026.md) · [US-027](user-stories/US-027.md) · [US-028](user-stories/US-028.md)

<!-- nav -->

---

[< Previous: 15. Monetization Model](15-monetization.md) | [Table of Contents](../product-spec.md)

<!-- nav -->
