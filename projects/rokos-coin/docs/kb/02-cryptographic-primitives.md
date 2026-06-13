# Cryptographic Primitives

The math that makes blockchains work. You don't need to implement these — libraries handle it — but you need to understand what they guarantee and where they break.

## Hash Functions

A hash function takes any input and produces a fixed-size output (the "hash" or "digest"). Blockchain uses them everywhere.

```
Input: "Hello"           → 0x185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969
Input: "Hello."          → 0x2d8bd7d9bb5f85ba643f0110d50cb506a1fe439234f234e2d3479c21d6cec802
Input: (1 GB file)       → 0x... (still 32 bytes)
```

**Properties that matter:**
- **Deterministic** — Same input always produces same output
- **Avalanche effect** — Tiny input change → completely different output
- **One-way** — Can't reverse a hash to find the input
- **Collision-resistant** — Astronomically hard to find two inputs with the same hash

**Hash functions in blockchain:**
| Function | Output | Used By |
|---|---|---|
| SHA-256 | 32 bytes | Bitcoin, most PoW chains |
| Keccak-256 | 32 bytes | Ethereum (often called SHA-3, but technically a pre-standardization variant) |
| BLAKE2b | Variable | Substrate/Polkadot |
| Poseidon | Variable | ZK-proof systems (designed for arithmetic circuits) |

**Practical uses:**
- Block hashing (linking blocks together)
- Transaction IDs
- Address derivation
- Merkle tree construction
- Proof of Work puzzle ("find a nonce where hash(block + nonce) starts with N zeroes")

## Digital Signatures

How you prove you authorized a transaction without revealing your private key.

### The Signing Process

```
1. Hash the message:     hash = keccak256("Send 1 ETH to Bob")
2. Sign with private key: signature = sign(hash, privateKey)
   → produces (r, s, v) — three numbers that together form the signature
3. Anyone can verify:    verify(hash, signature) → recovers the signer's public key
   → If recovered pubkey matches the sender's known pubkey, the signature is valid
```

### ECDSA (Elliptic Curve Digital Signature Algorithm)

The signature scheme used by Bitcoin and Ethereum. Based on the **secp256k1** elliptic curve.

**What you need to know:**
- Private key: 256-bit random number (looks like `0x4c0883a69102937d623...`)
- Public key: A point on the secp256k1 curve derived from the private key (64 bytes uncompressed)
- The math is irreversible: knowing the public key doesn't reveal the private key
- Ethereum addresses are the last 20 bytes of `keccak256(publicKey)`

**Why secp256k1?**
- Chosen by Satoshi for Bitcoin (no known backdoors, unlike NIST curves)
- Fast verification
- Compact signatures
- Widely implemented and audited

### EdDSA / Ed25519

An alternative signature scheme used by Solana, Cosmos, and newer chains:
- Faster than ECDSA
- Simpler implementation (less room for bugs)
- Deterministic signatures (no random nonce needed — eliminates a class of implementation bugs)
- Uses the Curve25519 elliptic curve

## Merkle Trees

A data structure that lets you prove a piece of data is part of a set without revealing the whole set.

```
                    Root Hash
                   /          \
            Hash(AB)          Hash(CD)
           /       \         /       \
      Hash(A)   Hash(B)  Hash(C)   Hash(D)
        |          |        |          |
      Tx A       Tx B     Tx C       Tx D
```

**How it works:**
1. Hash each transaction individually (leaf nodes)
2. Pair up hashes and hash them together (parent nodes)
3. Repeat until you get a single root hash (Merkle root)

**Why this matters:**
- The Merkle root in a block header summarizes all transactions in 32 bytes
- To prove Tx B is in the block, you only need: Hash(A) + Hash(CD) + Root
  - Verifier computes: Hash(Hash(A) + Hash(B)) = Hash(AB), then Hash(Hash(AB) + Hash(CD)) = Root ✓
  - This is a **Merkle proof** — logarithmic in size vs. the full transaction set
- Light clients (phones, browsers) use Merkle proofs to verify transactions without downloading the entire blockchain

**Variants:**
- **Patricia Merkle Trie** — Ethereum's state storage. Combines Merkle tree with a trie (prefix tree) to store key-value pairs efficiently. Enables "state proofs" — proving an account has a specific balance.
- **Sparse Merkle Tree** — Used in some L2s and ZK systems. Fixed-depth tree where most leaves are empty.

## Elliptic Curve Cryptography (ECC)

The math behind ECDSA and EdDSA. You'll never implement this, but the mental model helps.

An elliptic curve is a set of points satisfying: `y² = x³ + ax + b`

```
     •
    / \
   /   •----•
  •         |
   \       /
    •---•
       \
        •
```

**Key operation — Point multiplication:**
- Start with a base point G on the curve
- "Multiply" by a scalar (your private key): `PublicKey = privateKey × G`
- This operation is easy to compute forward but infeasible to reverse (the "discrete logarithm problem")
- This asymmetry is what makes the entire system work

**secp256k1 parameters (Ethereum/Bitcoin):**
- Curve: `y² = x³ + 7` (a=0, b=7)
- Field: 256-bit prime field
- Group order: ~2^256 (the number of possible private keys ≈ number of atoms in the universe)

## Zero-Knowledge Proofs (ZK)

A way to prove you know something without revealing what you know. Increasingly important in blockchain for privacy and scaling.

**The classic analogy:**
- I claim I can distinguish red from green (to a colorblind person)
- You hold a ball behind your back, maybe swap it, show me
- I consistently tell you whether you swapped it
- After 100 rounds, you're convinced I can see color — without me ever explaining how color works

**In blockchain:**
- **ZK-SNARKs** (Succinct Non-interactive Arguments of Knowledge) — Small proof, fast verification, requires trusted setup
- **ZK-STARKs** (Scalable Transparent Arguments of Knowledge) — No trusted setup, larger proofs, quantum-resistant
- **PLONK/Groth16/Halo2** — Specific proof systems (implementations of SNARKs)

**Where ZK is used:**
- **ZK-Rollups** (zkSync, Scroll, Polygon zkEVM) — Batch L2 transactions, prove validity on L1
- **Privacy coins** (Zcash) — Prove a transaction is valid without revealing sender, receiver, or amount
- **Identity** — Prove you're over 18 without revealing your birthdate

**Why this matters for rokos-coin:** ZK proofs could enable proving that computation was performed correctly without re-executing it — relevant for verifying miner contributions.

## Practical Cryptography Pitfalls

Things that go wrong in practice:

1. **Never roll your own crypto** — Use audited libraries (OpenZeppelin, libsodium, etc.)
2. **Private key management is the hard part** — The math is solid; the humans are the weak link
3. **Random number generation** — Bad randomness → predictable keys → stolen funds. Use hardware RNG or audited CSPRNG
4. **Signature malleability** — Some signature schemes allow creating different-looking signatures for the same message. Can cause transaction ID confusion.
5. **Hash collisions in practice** — SHA-256 and Keccak-256 are safe. MD5 and SHA-1 are broken. Know which you're using.
6. **Quantum computing** — ECDSA is theoretically vulnerable to quantum computers (Shor's algorithm). Not a threat yet, but post-quantum cryptography is being developed. ZK-STARKs are already quantum-resistant.

---
*Previous: [01-blockchain-fundamentals.md](01-blockchain-fundamentals.md) | Next: [03-consensus-mechanisms.md](03-consensus-mechanisms.md)*
