# CDN Distribution Architecture for Self-Hosted / Own-Hardware Streaming

> Technical reference for designing, building, and operating a content delivery network on owned or collocated hardware for live and on-demand video streaming.

---

## Table of Contents

1. [Origin Server Architecture](#1-origin-server-architecture)
2. [Edge Caching Strategies](#2-edge-caching-strategies)
3. [Network Topology for Distributed Delivery](#3-network-topology-for-distributed-delivery)
4. [CDN Peering and Federation](#4-cdn-peering-and-federation)
5. [Load Balancing for Streaming](#5-load-balancing-for-streaming)
6. [Bandwidth Cost Modeling](#6-bandwidth-cost-modeling)
7. [DNS-Based Geographic Routing](#7-dns-based-geographic-routing)
8. [Multicast vs Unicast Tradeoffs](#8-multicast-vs-unicast-tradeoffs)

---

## 1. Origin Server Architecture

### 1.1 Origin Design Patterns

#### Single Origin

The simplest deployment: one origin server (or a small active-passive pair behind a VIP) that serves as the authoritative source for all content. All edge PoPs pull from this single location.

**When to use:**
- Fewer than 3 edge locations
- All infrastructure in one geographic region
- VOD-heavy workloads with low concurrency (< 500 concurrent viewers)

**Limitations:**
- Single point of failure
- Bandwidth bottleneck at the origin's uplink
- Latency penalty for geographically distant edges

#### Multi-Origin with Replication

Multiple origin servers replicate content across sites. Replication strategies:

| Strategy | Mechanism | Latency | Consistency | Complexity |
|----------|-----------|---------|-------------|------------|
| Active-passive | Primary serves; secondary replicates via rsync/rclone | Failover delay | eventual | Low |
| Active-active | All origins serve; write to one, sync to others | None (any origin serves) | eventual | Medium |
| Shared storage | Origins read from shared object storage (MinIO, Ceph) | None | strong | Medium |
| Database-backed | Metadata in DB, segments in object storage | None | strong | High |

**Recommended for self-hosted:** Object storage backend (MinIO cluster) with multiple nginx origins fronting it. Origins are stateless -- they serve from the same backing store.

```
                    +------------------+
                    |   MinIO / Ceph   |
                    |  (Object Store)  |
                    +--------+---------+
                             |
              +--------------+--------------+
              |              |              |
        +-----+----+  +-----+----+  +-----+----+
        | Origin 1  |  | Origin 2  |  | Origin 3  |
        | (nginx)   |  | (nginx)   |  | (nginx)   |
        +-----+----+  +-----+----+  +-----+----+
              |              |              |
         Site A          Site B          Site C
```

### 1.2 Origin Shielding / Mid-Tier Caching

An origin shield is a caching reverse proxy placed between the edge PoPs and the origin. It collapses duplicate requests and absorbs origin load.

**Architecture:**

```
Edge PoPs (many)
    |
    +---> Origin Shield (1-2, regional)
              |
              +---> Origin Server(s)
```

**Purpose:**
- If 50 edge PoPs all request the same 2-second segment simultaneously, the shield makes only 1 request to the origin and serves the other 49 from cache.
- Reduces origin egress bandwidth by 90-98% for popular content.
- Provides a controlled point for header manipulation and cache policy enforcement.

**Nginx origin shield configuration:**

```nginx
proxy_cache_path /var/cache/nginx/shield
    levels=1:2
    keys_zone=shield:512m        # ~4M keys at 128 bytes each
    max_size=500g                 # disk cache size
    inactive=72h                  # evict after 72h of no access
    use_temp_path=off;            # avoid cross-disk copy

server {
    listen 443 ssl http2;
    server_name shield.cdn.example.com;

    ssl_certificate     /etc/nginx/ssl/shield.crt;
    ssl_certificate_key /etc/nginx/ssl/shield.key;

    # Shield auth: only allow known edge PoPs
    allow 10.0.1.0/24;      # Edge PoP subnet A
    allow 10.0.2.0/24;      # Edge PoP subnet B
    deny all;

    location ~ \.m3u8$ {
        proxy_pass         http://origin-backend;
        proxy_cache         shield;
        proxy_cache_valid   200 5s;       # Live manifest: 5s TTL
        proxy_cache_valid   404 1s;
        proxy_cache_lock    on;            # Collapse concurrent misses
        proxy_cache_use_stale updating;    # Serve stale while refreshing
        add_header X-Cache-Status $upstream_cache_status;
    }

    location ~ \.mpd$ {
        proxy_pass         http://origin-backend;
        proxy_cache         shield;
        proxy_cache_valid   200 5s;
        proxy_cache_lock    on;
        proxy_cache_use_stale updating;
        add_header X-Cache-Status $upstream_cache_status;
    }

    location ~ \.(ts|m4s|mp4)$ {
        proxy_pass         http://origin-backend;
        proxy_cache         shield;
        proxy_cache_valid   200 48h;      # Segments: long TTL (immutable)
        proxy_cache_lock    on;
        add_header X-Cache-Status $upstream_cache_status;
        add_header Cache-Control "public, max-age=172800, immutable";
    }
}
```

### 1.3 Origin Pull vs Push Models

| Aspect | Pull Model | Push Model |
|--------|-----------|------------|
| How content arrives | Edge fetches on first client request | Origin proactively uploads to edges |
| First-request latency | Higher (cache miss path) | Near-zero (pre-populated) |
| Operational complexity | Lower | Higher (push orchestration) |
| Storage efficiency | Caches only what is requested | May cache content nobody watches |
| Best for | VOD catalogs, long-tail content | Live events, premieres, popular VOD |
| Implementation | Standard reverse proxy cache | rsync, rclone, S3 replication, custom scripts |

**Recommendation:** Use pull as the default. Add push/warm for live events where first-request latency is unacceptable.

### 1.4 Nginx Origin Configuration for HLS/DASH

#### Optimal Proxy Settings for Streaming

```nginx
# Connection and timeout tuning
proxy_connect_timeout   5s;       # Time to establish connection to upstream
proxy_send_timeout      180s;     # Time between two successive writes to upstream
proxy_read_timeout      180s;     # Time between two successive reads from upstream

# Buffer tuning for video segments (avoid excessive buffering)
proxy_buffering         on;       # Buffer responses for cache efficiency
proxy_buffer_size       16k;      # Response header buffer
proxy_buffers           512 32k;  # Response body buffers
proxy_temp_file_write_size 512k;  # Write chunk size for spillover to disk
proxy_max_temp_file_size 256m;    # Max temp file per request

# For LOW-LATENCY HLS/DASH (chunked transfer):
# proxy_buffering must be OFF or use chunked-proxy module
# proxy_buffering off;
# Standard proxy_cache_lock is NOT suitable for LL-HLS chunked transfer.
# Use the nginx chunked-proxy module or proxy_pass with no buffering.
```

#### Origin Server Full Example

```nginx
upstream packager_backend {
    server 127.0.0.1:8080;  # FFmpeg/Shaka Packager
    keepalive 64;            # Persistent connections to packager
}

server {
    listen 443 ssl http2;
    server_name origin.cdn.example.com;

    ssl_certificate     /etc/nginx/ssl/origin.crt;
    ssl_certificate_key /etc/nginx/ssl/origin.key;

    # Gzip only manifests, not video segments (already compressed codecs)
    gzip on;
    gzip_types application/vnd.apple.mpegurl application/dash+xml;
    gzip_min_length 256;

    # Connection limits
    limit_conn addr 100;  # Max 100 concurrent connections per IP

    location /live/ {
        proxy_pass http://packager_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";

        # Live manifests: short TTL, allow stale during revalidation
        location ~ \.m3u8$ {
            proxy_pass http://packager_backend;
            add_header Cache-Control "public, max-age=2, stale-while-revalidate=5";
            add_header Access-Control-Allow-Origin "*";
            add_header Access-Control-Allow-Methods "GET, OPTIONS";
        }

        location ~ \.mpd$ {
            proxy_pass http://packager_backend;
            add_header Cache-Control "public, max-age=2, stale-while-revalidate=5";
            add_header Access-Control-Allow-Origin "*";
        }

        # Video segments: immutable once published
        location ~ \.(ts|m4s)$ {
            proxy_pass http://packager_backend;
            add_header Cache-Control "public, max-age=86400, immutable";
        }
    }

    location /vod/ {
        alias /media/vod/;

        # VOD manifests: longer TTL (content is static)
        location ~ \.m3u8$ {
            add_header Cache-Control "public, max-age=300";
            add_header Access-Control-Allow-Origin "*";
        }

        location ~ \.mpd$ {
            add_header Cache-Control "public, max-age=300";
            add_header Access-Control-Allow-Origin "*";
        }

        # VOD segments: effectively immutable
        location ~ \.(ts|m4s|mp4|init)$ {
            add_header Cache-Control "public, max-age=604800, immutable";
        }
    }

    # Health check endpoint
    location /healthz {
        return 200 "ok\n";
        access_log off;
    }
}
```

### 1.5 Header Management

#### Cache-Control Directives for Streaming

| Content Type | Recommended Cache-Control | Rationale |
|-------------|--------------------------|-----------|
| Live manifest (.m3u8, .mpd) | `max-age=2, stale-while-revalidate=5` | Must refresh fast; stale-while-revalidate prevents thundering herd |
| VOD manifest | `max-age=300` | Static content; 5 min is safe |
| Init segments (.init.mp4, .m4s) | `max-age=86400, immutable` | Never changes for a given stream |
| Media segments (.ts, .m4s) | `max-age=172800, immutable` | Immutable once encoded |
| DRM license | `no-store` or `private, max-age=0` | Never cache at CDN edge |
| Encryption keys | `private, max-age=0` | Session-specific |

#### ETags

ETags enable conditional requests (304 Not Modified) to avoid retransmitting unchanged content. Nginx has built-in ETag support since 1.7.3.

- For static files on disk: Nginx auto-generates ETags from file modification time and size.
- For proxied content: ETags pass through from the upstream.
- For live streaming: ETags are less useful because manifests change every segment duration.
- For VOD segments: ETags provide strong validation. The cache slice module uses ETags to detect if the underlying file has changed during a range request.

### 1.6 Origin Failover Strategies

#### Active-Passive with Health Checks

```nginx
upstream origin_backend {
    server origin-a.internal:443 max_fails=3 fail_timeout=10s;
    server origin-b.internal:443 backup;  # Only used when primary fails
    keepalive 64;
}
```

#### Active-Active with Load Balancing

```nginx
upstream origin_backend {
    least_conn;  # Prefer origin with fewest active connections
    server origin-a.internal:443 max_fails=3 fail_timeout=10s;
    server origin-b.internal:443 max_fails=3 fail_timeout=10s;
    keepalive 64;
}
```

#### Failover Decision Matrix

| Strategy | Failover Time | Data Consistency Risk | Complexity |
|----------|--------------|----------------------|------------|
| DNS failover (low TTL) | 5-30 seconds | Low (if TTL respected) | Low |
| BGP anycast withdrawal | Sub-second | None | High (requires ASN) |
| Nginx upstream failover | Immediate (per-request) | Low | Low |
| Global server load balancing | 10-60 seconds | Low | Medium |

---

## 2. Edge Caching Strategies

### 2.1 Cache Hierarchy Design

A three-tier cache hierarchy is the industry standard for streaming CDNs:

```
Tier 1: Edge PoP (closest to viewer)
    |   Cache: hot segments only
    |   Hit ratio target: 85-95%
    |
Tier 2: Regional Shield (1 per geographic region)
    |   Cache: warm + hot segments
    |   Hit ratio target: 95-99%
    |
Tier 3: Origin Shield (1-2 globally)
    |   Cache: full catalog
    |   Hit ratio target: 99%+
    |
Origin Server(s)
```

**Latency budget:**
- Viewer to Edge: < 30ms RTT
- Edge to Regional Shield: < 50ms RTT
- Regional Shield to Origin Shield: < 100ms RTT
- Origin Shield to Origin: < 5ms RTT (same datacenter ideally)

**Total worst-case (cache miss all tiers):** ~185ms for first byte. After warming, typical is 10-30ms.

### 2.2 Cache Key Design

The cache key determines whether two requests are considered the same content. Poor cache key design destroys hit ratios.

#### Recommended Cache Key Components

```nginx
# Cache key: URI + variant query params only
proxy_cache_key "$scheme$request_method$host$uri$is_args$args";

# For multi-bitrate streams, include variant in key:
# proxy_cache_key "$host$uri$arg_bitrate";

# Exclude tracking/analytics query params:
# /video/segment.ts?token=abc123  vs  /video/segment.ts?token=xyz789
# These are THE SAME segment but different tokens will cause cache misses
```

#### Cache Key Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Including session tokens in key | Every user gets a cache miss | Normalize key: strip auth tokens |
| Including random cache-busters | Defeats caching entirely | Remove bust params from key |
| Different URL paths for same content | /live/stream vs /live/stream/ | Canonicalize URLs |
| Including `Accept` header | Different device types = different keys | Use only URL-based keys |

#### Segment-Level Cache Key Design

For HLS/DASH, the natural granularity is the segment:

```
/live/sports/video/1080p/segment_00042.ts  -> unique cache entry
/live/sports/audio/128k/segment_00042.ts   -> unique cache entry
/live/sports/video/1080p/segment_00043.ts  -> unique cache entry
```

### 2.3 Cache Warming and Preloading

#### For Live Events

Before a major live event (sports, concert, keynote):

1. **Pre-populate edge caches with initialization segments**: Push `.init.mp4` and the first few segments to all edges 15-30 minutes before the event starts.

2. **Manifest preheating**: Use a script to repeatedly request the manifest from each edge to ensure it is cached before viewers arrive.

3. **Hot-segment pinning**: Keep the latest 3 segments in RAM (not disk) for microsecond seek times. Nginx config:

```nginx
proxy_cache_path /dev/shm/nginx-cache/hot
    levels=1:2
    keys_zone=hot_segments:64m
    max_size=2g
    inactive=30s;     # Aggressive eviction for hot cache
```

4. **Automated warming script:**

```bash
#!/bin/bash
# Pre-warm edge caches before a live event
EDGES=("edge-us-east.cdn.example.com" "edge-us-west.cdn.example.com" "edge-eu.cdn.example.com")
STREAM="live/event-keynote"

for edge in "${EDGES[@]}"; do
    echo "Warming $edge..."
    # Fetch manifest to cache it
    curl -s "https://$edge/$STREAM/manifest.m3u8" > /dev/null
    # Fetch init segments
    curl -s "https://$edge/$STREAM/video/init.mp4" > /dev/null
    curl -s "https://$edge/$STREAM/audio/init.mp4" > /dev/null
    # Fetch last 3 segments from each quality level
    for q in 360p 720p 1080p; do
        for i in 40 41 42; do
            curl -s "https://$edge/$STREAM/video/$q/segment_$(printf '%05d' $i).m4s" > /dev/null &
        done
    done
    wait
done
```

#### For VOD Catalogs

- Use a background job to fetch recently-added content manifests and first few segments from each edge.
- Priority queue: warm the top N most-popular items first (based on analytics).
- Typical warm window: warm new content within 5 minutes of ingest.

### 2.4 Cache Invalidation Approaches

| Method | Speed | Scope | Complexity | Use Case |
|--------|-------|-------|------------|----------|
| TTL expiry (natural) | Slow (waits for TTL) | Per-object | Zero | Default for all content |
| Purge API (nginx: `proxy_cache_purge`) | Instant | Per-URL or wildcard | Low | Content updates |
| Full cache clear (`rm -rf` cache dir) | Fast | Entire cache | Low (but disruptive) | Emergency only |
| Versioned URLs (`/v2/segment.ts`) | Instant | New objects | Medium | VOD releases |
| Surrogate keys (Varnish, Fastly) | Instant | Per-tag group | Medium | Multi-asset invalidation |

**Nginx cache purge example (requires `ngx_cache_purge` module):**

```nginx
location ~ /purge(/.*) {
    allow 10.0.0.0/8;  # Only internal networks
    deny all;
    proxy_cache_purge shield $1$is_args$args;
}
```

### 2.5 Stale Content Strategies

#### stale-while-revalidate

The edge serves stale content while fetching a fresh copy in the background. Critical for live manifests to prevent request coalescence (thundering herd).

```nginx
proxy_cache_use_stale updating;     # Serve stale while revalidating
proxy_cache_background_update on;   # Initiate background fetch
proxy_cache_lock on;                 # Only one request goes to origin
proxy_cache_lock_timeout 5s;        # After 5s, serve stale even if still locked
```

**Effect on latency:**
- p50: unchanged (cache hit)
- p95: stays flat (stale served immediately)
- Without this: p95 spikes during revalidation because all viewers wait for the origin fetch

#### stale-if-error

Serves stale content when the origin is unavailable.

```nginx
# In Cache-Control header from origin:
# Cache-Control: max-age=5, stale-while-revalidate=10, stale-if-error=300
```

This means:
- Fresh for 5 seconds
- Can serve stale for up to 10 seconds while revalidating in background
- If origin returns error, serve stale for up to 300 seconds (5 minutes)

### 2.6 Segment-Level vs Object-Level Caching

| Aspect | Segment-Level | Object-Level (full file) |
|--------|--------------|------------------------|
| Granularity | Individual .ts/.m4s files | Full .mp4 files with byte-range requests |
| Cache efficiency | High (small, discrete objects) | Lower (requires range caching support) |
| Memory overhead | Lower (smaller objects) | Higher (metadata for large files) |
| Seek performance | O(1) -- fetch the needed segment | Requires range request handling |
| Best for | HLS/DASH (standard) | Progressive download, MP4 pseudo-streaming |

**Recommendation:** Use segment-level caching for HLS/DASH. If you must serve progressive MP4 downloads, enable byte-range caching:

```nginx
# Byte-range caching for large MP4 files
slice              1m;              # Slice large files into 1MB chunks
proxy_cache_key    "$host$uri$slice_range";
proxy_set_header   Range $slice_range;
proxy_cache_valid  200 206 48h;
```

### 2.7 Manifest/Playlist Caching

The manifest is the single most critical caching decision in a streaming CDN.

#### Live Manifests

```
Refresh window = segment duration (typically 2-6 seconds)
TTL must be < half the segment duration to ensure timely updates
```

| Segment Duration | Recommended Manifest TTL |
|-----------------|--------------------------|
| 2s | 1s |
| 4s | 2s |
| 6s | 3s |
| 10s | 4s |

**Always pair with `stale-while-revalidate`** to prevent the thundering herd problem when the manifest expires.

#### VOD Manifests

VOD manifests are static. Cache aggressively:

```
Cache-Control: public, max-age=300, stale-while-revalidate=3600
```

Invalidate only when the VOD asset is updated (rare) or DRM keys rotate.

### 2.8 Cache Hit Ratio Optimization

#### Target Hit Ratios

| Tier | Target Hit Ratio | What drives misses |
|------|-----------------|-------------------|
| Edge | 85-95% | Long-tail content, first viewer of unpopular content |
| Regional Shield | 95-99% | Content not requested in that region yet |
| Origin Shield | 99%+ | Truly new content, first request globally |

#### Optimization Techniques

1. **Increase cache size**: A general rule is 1 GB of cache per 100 concurrent viewers for live content. For VOD, size based on catalog.

2. **Cache key normalization**: Strip analytics tokens, session IDs, and other non-content query parameters.

3. **Object prefetching**: Preload the next segment based on manifest parsing.

4. **Separate cache zones by content type:**

```nginx
proxy_cache_path /var/cache/nginx/manifests
    keys_zone=manifests:64m max_size=10g inactive=30s;

proxy_cache_path /var/cache/nginx/segments
    keys_zone=segments:512m max_size=500g inactive=48h;

proxy_cache_path /var/cache/nginx/init-segments
    keys_zone=init_segments:32m max_size=5g inactive=72h;
```

5. **Vary-aware caching**: Do not use the `Vary` header for streaming content unless you serve different encodings at the same URL (rare). Each variant should have a unique URL.

---

## 3. Network Topology for Distributed Delivery

### 3.1 Topology Patterns

#### Hub-and-Spoke

```
                  Origin (Hub)
                 /     |      \
               /       |        \
          Edge A    Edge B    Edge C
          (spoke)   (spoke)   (spoke)
```

**Characteristics:**
- All edges communicate only with the origin/shield
- Simple to operate and reason about
- Origin/shield is a bottleneck if many edges request simultaneously
- Suitable for: 3-10 PoPs, moderate concurrency

#### Mesh

```
          Origin
         /  |  \
        /   |   \
    Edge A -- Edge B -- Edge C
        \   |   /
         \  |  /
           Origin
```

**Characteristics:**
- Edges can fetch from each other (or from any other edge)
- Better resilience (multiple paths to content)
- Complex routing and cache coherency
- Suitable for: 5-20 PoPs with inter-PoP links

#### Hierarchical (Recommended for Most Self-Hosted Deployments)

```
                    Origin
                      |
                Origin Shield (Tier 3)
                /             \
        Regional A         Regional B    (Tier 2)
        /    |    \        /    |    \
     E1    E2    E3     E4    E5    E6  (Tier 1)
```

**Characteristics:**
- Clear separation of concerns at each tier
- Origin load scales with number of regions, not number of edges
- Each tier can have different caching policy
- Suitable for: 10+ PoPs across multiple regions

### 3.2 Anycast Routing for CDN

BGP Anycast allows multiple servers at different locations to share the same IP address. BGP automatically routes each client to the topologically nearest server.

#### How It Works

1. You announce the same IP prefix (e.g., `203.0.113.0/24`) from all PoP locations via BGP.
2. Each PoP's upstream BGP router advertises this prefix to its peers and transits.
3. Client routers select the shortest AS-path to the prefix.
4. Traffic naturally flows to the nearest PoP.

#### Requirements

| Requirement | Details |
|-------------|---------|
| ASN | Your own AS number (or piggyback on a hosting provider's) |
| IP space | Provider-Independent (PI) address space, at least a /24 |
| BGP router | Hardware (Mikrotik, Juniper) or software (BIRD, FRRouting, ExaBGP) |
| Peering | At least one transit provider per PoP willing to carry your anycast prefix |
| Consistent state | All anycast nodes must serve identical content |

#### BIRD Configuration Example

```bash
# /etc/bird/bird.conf on each PoP
router id 10.0.1.1;   # Unique per PoP

protocol bgp anycast_upstream {
    local as 65000;           # Your ASN
    neighbor 198.51.100.1 as 64512;  # Upstream provider
    export filter {
        if net = 203.0.113.0/24 then accept;  # Your anycast prefix
        reject;
    };
    import all;
}
```

#### Anycast Limitations

- No connection-level failover: if a PoP goes down mid-stream, the TCP connection drops. The client must reconnect (the player does this automatically for HLS/DASH).
- BGP convergence: when a PoP withdraws its route, convergence takes 30-90 seconds globally. During this window, some clients may try to reach the withdrawn PoP.
- Not a substitute for health checking: you still need per-PoP health monitoring and automated BGP withdrawals when a PoP becomes unhealthy.

### 3.3 DNS-Based Geographic Routing

For operators without their own ASN, DNS-based routing is the primary alternative. See Section 7 for full details.

**Quick comparison with anycast:**

| Aspect | Anycast | GeoDNS |
|--------|---------|--------|
| Routing granularity | Network topology (BGP path) | Geographic (IP-to-location mapping) |
| Failover speed | 30-90s (BGP convergence) | TTL + client DNS cache (5-300s) |
| Accuracy | Good (follows network topology) | Variable (depends on MaxMind accuracy) |
| Cost | High (ASN, BGP routers) | Low-Medium (DNS service or self-hosted) |
| Connection affinity | None (stateless) | None |
| Required for | Multi-region with own ASN | Most self-hosted setups |

### 3.4 PoP Placement Strategy

#### How Many PoPs?

| Concurrent Viewers | Geographic Spread | Recommended PoPs |
|-------------------|-------------------|-----------------|
| < 1,000 | Single country | 1-2 (with origin shield) |
| 1,000 - 10,000 | Single continent | 3-5 (regional) |
| 10,000 - 100,000 | Multi-continental | 8-15 (major IXPs) |
| 100,000+ | Global | 15-30+ (major + minor IXPs) |

#### Where to Place PoPs

**Prioritize locations by:**

1. **Proximity to viewers**: Place PoPs at internet exchange points (IXPs) in cities with the highest viewer density. Use analytics to identify viewer clusters.

2. **Peering density**: An IXP with 800+ peers gives you direct paths to many eyeball networks, reducing transit cost and latency.

3. **Latency targets**: Each viewer should be within 30ms RTT of a PoP. In North America, this typically means PoPs on the East Coast, West Coast, and Central US at minimum.

4. **Cost of bandwidth**: Prioritize locations with cheap transit or free peering (AMS-IX, DE-CIX, LINX in Europe; NOTT and Equinix in North America).

**Major IXP locations for self-hosted CDN:**

| Region | IXPs to Consider |
|--------|-----------------|
| North America | NOTT (Toronto), Equinix (Ashburn, Chicago, San Jose), SEA-IX (Seattle) |
| Europe | AMS-IX (Amsterdam), DE-CIX (Frankfurt), LINX (London), France-IX (Paris) |
| Asia | HKIX (Hong Kong), JPNAP (Tokyo), SGIX (Singapore) |

### 3.5 Latency Optimization

#### TCP Optimization

```nginx
# In nginx.conf (requires root)
sendfile on;
tcp_nopush on;        # Send headers in one packet
tcp_nodelay on;       # Disable Nagle's algorithm for small packets

# Kernel tuning (sysctl.conf)
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 5
net.core.netdev_max_backlog = 65535
```

#### Connection Pooling

```nginx
upstream origin {
    server origin.internal:443;
    keepalive 128;           # Pool of 128 persistent connections
    keepalive_requests 10000; # Recycle after 10k requests
    keepalive_timeout 60s;    # Idle timeout for pooled connections
}
```

#### HTTP/2 and HTTP/3

- **HTTP/2**: Multiplexing eliminates head-of-line blocking at the HTTP layer. Enable on all edge servers.
- **HTTP/3 (QUIC)**: Eliminates head-of-line blocking at the transport layer. Reduces connection establishment time (0-RTT). Recommended for mobile viewers on high-latency paths.

```nginx
# HTTP/3 (nginx 1.25+)
listen 443 quic reuseport;
listen 443 ssl;
http2 on;

# Advertise HTTP/3 via Alt-Svc header
add_header Alt-Svc 'h3=":443"; ma=86400';
```

### 3.6 Peering Strategy

#### IX Peering

At an internet exchange point, you connect your router to a shared switching fabric and establish direct BGP sessions with other networks.

**Cost:** IX port fees are typically fixed monthly charges regardless of traffic volume.

| IXP | Port Cost (approximate) |
|-----|------------------------|
| AMS-IX (1G) | ~EUR 400/month |
| DE-CIX (1G) | ~EUR 350/month |
| LINX (1G) | ~GBP 300/month |
| Equinix (1G) | ~USD 500-800/month |

Once connected, peering is often settlement-free (free) with major eyeball networks, meaning you exchange traffic at zero marginal cost.

#### Private Peering

Direct physical connection between your router and a specific network. Typically a cross-connect in a datacenter.

**When to use:** When you exchange > 5 Gbps with a single network and settlement-free peering is not available.

**Cost:** Cross-connect fee (typically $100-500/month) + any agreed settlement rate.

#### Transit

When you cannot reach a network via peering, you use a transit provider who carries your traffic to all destinations.

**Cost (2026 market rates):**

| Commit Level | Price per Mbps/month | Price per GB |
|-------------|---------------------|-------------|
| 1 Gbps committed | $0.50 - $1.50 | $0.01 - $0.03 |
| 10 Gbps committed | $0.15 - $0.50 | $0.003 - $0.01 |
| 100 Gbps committed | $0.05 - $0.15 | $0.001 - $0.003 |

**Strategy:** Peering for high-volume eyeball networks (ISPs), transit for everything else.

---

## 4. CDN Peering and Federation

### 4.1 Multi-CDN Strategies

#### Primary/Failover

```
                  DNS/GSLB
                  /       \
           Primary CDN    Secondary CDN
           (100% traffic)  (0% until failover)
```

- Simplest to operate
- Failover via DNS TTL expiry or anycast withdrawal
- Secondary CDN may have stale cache after failover (cold start problem)
- Mitigation: send a small percentage (1-5%) of traffic to secondary continuously to keep caches warm

#### Load Split (Active-Active)

```
                  DNS/GSLB
                  /       \
           CDN A (60%)    CDN B (40%)
```

- Both CDNs serve traffic simultaneously
- Load distribution can be percentage-based, performance-based, or cost-based
- Better resilience (both are always warm)
- More complex monitoring and troubleshooting

#### Geographic Split

```
                  DNS/GSLB
                /    |     \
         CDN A     CDN B     CDN C
         (Americas) (Europe)  (Asia-Pacific)
```

- Each CDN serves its strongest region
- Requires deep GeoDNS integration
- Best performance per region
- Complex failover (must reroute regions between CDNs)

### 4.2 CDN Federation Protocols

CDN Federation allows independent CDN operators to interconnect and exchange traffic. The primary standard is **CDNI (CDN Interconnection)**, defined in RFCs 6707, 8006, 8007, 8008, and 8496.

#### CDNI Components

| Component | Purpose | Protocol |
|-----------|---------|----------|
| Footprint and Capabilities (FCI) | Advertise which regions each CDN serves and what capabilities it has | HTTP-based REST API |
| Request Routing | Redirect a user from one CDN to another | DNS or HTTP redirect |
| Metadata Interface | Exchange content metadata (cache policy, geo-restrictions) | REST API |
| Logging | Exchange delivery metrics between CDNs | File-based (CDNI Logging) |

#### Practical Federation for Self-Hosted

For self-hosted CDNs, full CDNI is often overkill. A practical federation approach:

1. **Shared origin**: All CDN nodes pull from the same origin (or origin shield).
2. **DNS-based routing**: A central GeoDNS server directs viewers to the nearest node.
3. **Health checking**: Each node reports health to the DNS server via a simple HTTP heartbeat.
4. **Cache consistency**: Since all nodes pull from the same origin, consistency is inherent.

### 4.3 Building Your Own CDN Federation

#### Architecture for Owned Hardware at Multiple Sites

```
Site A (New York)              Site B (Amsterdam)           Site C (Tokyo)
+-------------------+          +-------------------+        +-------------------+
| Edge Node A       |          | Edge Node B       |        | Edge Node C       |
| (nginx + cache)   |          | (nginx + cache)   |        | (nginx + cache)   |
| Health Reporter   |          | Health Reporter   |        | Health Reporter   |
+--------+----------+          +--------+----------+        +--------+----------+
         |                              |                             |
         +------------------------------+-----------------------------+
                    Mesh VPN Overlay (WireGuard / Tailscale)
         +------------------------------+-----------------------------+
         |                                                             |
   Central Management (GeoDNS + Monitoring + Config Distribution)
```

#### Step-by-Step Build

**1. Acquire hardware or VMs at each site:**

Minimum per PoP for a streaming edge:
- CPU: 4-8 cores (modern, e.g., AMD EPYC or Intel Xeon)
- RAM: 16-32 GB (cache index + OS + nginx workers)
- Disk: 500 GB - 2 TB NVMe (for segment cache)
- Network: 1 Gbps uplink minimum; 10 Gbps for high-traffic PoPs

**2. Install and configure nginx at each site:**

Use the edge caching configuration from Section 2, with each site pointing to the origin shield as its upstream.

**3. Set up the inter-site network:**

```bash
# WireGuard mesh example (each node connects to all others)
# /etc/wireguard/wg0.conf on Node A
[Interface]
Address = 10.200.0.1/24
ListenPort = 51820
PrivateKey = <node-a-private-key>

[Peer]  # Node B
PublicKey = <node-b-public-key>
AllowedIPs = 10.200.0.2/32
Endpoint = amsterdam.example.com:51820

[Peer]  # Node C
PublicKey = <node-c-public-key>
AllowedIPs = 10.200.0.3/32
Endpoint = tokyo.example.com:51820
```

**4. Deploy GeoDNS** (see Section 7).

**5. Implement health checking:**

```bash
#!/bin/bash
# /usr/local/bin/health-report.sh (runs on each edge via cron every 30s)
# Reports health to central GeoDNS controller

ENDPOINT="https://geodns.example.com/health-report"
NODE_ID="edge-us-east"

# Check local nginx is responding
if curl -sf -o /dev/null -m 5 https://localhost/healthz; then
    STATUS="healthy"
else
    STATUS="unhealthy"
fi

# Check disk space
DISK_PCT=$(df -h /var/cache/nginx | awk 'NR==2{print $5}' | tr -d '%')

# Report to central controller
curl -sf -X POST "$ENDPOINT" \
    -H "Content-Type: application/json" \
    -d "{\"node\": \"$NODE_ID\", \"status\": \"$STATUS\", \"disk_pct\": $DISK_PCT}"
```

### 4.4 Traffic Routing Between PoPs

When an edge PoP receives a request for content it does not have cached, it must decide where to fetch it from.

#### Routing Options

| Strategy | How | Latency | Cache Efficiency |
|----------|-----|---------|-----------------|
| Always go to origin | Single upstream | High | Good (single cache tier) |
| Go to regional shield first | Tiered upstream | Medium | Best |
| Ask other PoPs | Mesh fetch | Variable | Good (but complex) |
| Redirect client to different PoP | HTTP 302 | Client-side | No cache benefit |

**Recommended:** Tiered upstream (regional shield, then origin shield):

```nginx
upstream content_source {
    server regional-shield.internal:443;     # Try regional shield first
    server origin-shield.internal:443 backup; # Fall back to origin shield
}
```

### 4.5 Health Checking and Automatic Failover

#### Health Check Matrix

| Check Type | Interval | Timeout | Failure Threshold | Action |
|-----------|----------|---------|-------------------|--------|
| HTTP healthz | 5s | 2s | 3 consecutive failures | Remove from DNS |
| TCP connect | 5s | 1s | 3 consecutive failures | Remove from DNS |
| Cache fill rate | 30s | N/A | < 80% for 3 checks | Alert, no removal |
| Disk usage | 60s | N/A | > 90% | Trigger cache eviction |
| Bandwidth saturation | 10s | N/A | > 85% of uplink | Alert, consider load shed |

#### Automated Failover Flow

```
Health check fails (3x consecutive)
    |
    v
DNS controller removes PoP from rotation
    |
    v
DNS TTL expires (e.g., 30s)
    |
    v
New viewers route to next-nearest PoP
    |
    v
Existing connections on failed PoP time out
    |
    v
Players automatically reconnect to new PoP (HLS/DASH self-heals)
```

---

## 5. Load Balancing for Streaming

### 5.1 L4 vs L7 Load Balancing

| Aspect | L4 (Transport) | L7 (Application) |
|--------|----------------|-------------------|
| Operates at | TCP/UDP | HTTP/HTTPS |
| Sees | Source/destination IP:port | Full HTTP request, URL, headers |
| SSL termination | No (passthrough) | Yes |
| Routing based on | IP+port, connection count | URL path, headers, cookies |
| Overhead | Very low | Moderate (HTTP parsing) |
| Connection draining | Harder (no awareness of stream state) | Easier (can wait for manifest request completion) |
| Best for | Front-line load balancer, DDoS absorption | Content-aware routing, rate limiting |

**Recommended architecture for streaming:**

```
Clients
    |
L4 Load Balancer (HAProxy mode tcp or keepalived/IPVS)
    |   Handles millions of connections with minimal overhead
    |   SSL passthrough or termination here
    |
L7 Load Balancer / Ingress (Nginx or Envoy)
    |   URL-based routing
    |   Rate limiting, auth, header manipulation
    |
Nginx Edge Cache (multiple instances)
    |
Origin Shield / Origin
```

### 5.2 HAProxy Configuration for HLS/DASH

```haproxy
# /etc/haproxy/haproxy.cfg

global
    maxconn 100000
    tune.ssl.default-dh-param 2048
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256

defaults
    mode http
    timeout connect 5s
    timeout client  300s    # Long timeout for streaming
    timeout server  300s
    timeout tunnel  3600s   # WebSocket / long-lived connections

frontend streaming_frontend
    bind *:443 ssl crt /etc/haproxy/ssl/cdn.pem alpn h2,http/1.1
    mode http

    # Rate limiting (100 requests/second per IP)
    stick-table type ip size 1m expire 60s store conn_rate(100s)
    http-request track-sc0 src
    http-request deny deny_status 429 if { sc_conn_rate(0) gt 100 }

    # Connection limit (50 concurrent per IP)
    stick-table type ip size 1m expire 60s store conn_cnt
    http-request track-sc1 src
    http-request deny deny_status 429 if { sc_conn_cnt(1) gt 50 }

    # Route by content type
    acl is_manifest path_end .m3u8 .mpd
    acl is_segment  path_end .ts .m4s .mp4

    use_backend edge_manifest if is_manifest
    use_backend edge_segments if is_segment
    default_backend edge_default

backend edge_manifest
    balance leastconn
    option httpchk GET /healthz
    http-check expect status 200

    server edge1 10.0.1.10:443 ssl verify none check inter 5s fall 3 rise 2
    server edge2 10.0.1.11:443 ssl verify none check inter 5s fall 3 rise 2
    server edge3 10.0.1.12:443 ssl verify none check inter 5s fall 3 rise 2

    # Short timeout for manifest requests
    timeout server 10s

backend edge_segments
    balance leastconn
    option httpchk GET /healthz
    http-check expect status 200

    server edge1 10.0.1.10:443 ssl verify none check inter 5s fall 3 rise 2
    server edge2 10.0.1.11:443 ssl verify none check inter 5s fall 3 rise 2
    server edge3 10.0.1.12:443 ssl verify none check inter 5s fall 3 rise 2

    # Longer timeout for segment delivery
    timeout server 60s
    timeout tunnel 3600s
```

### 5.3 Nginx as Load Balancer

```nginx
upstream edge_pool {
    least_conn;
    server 10.0.1.10:443 max_fails=3 fail_timeout=10s;
    server 10.0.1.11:443 max_fails=3 fail_timeout=10s;
    server 10.0.1.12:443 max_fails=3 fail_timeout=10s;

    keepalive 128;
}

server {
    listen 443 ssl http2;
    server_name cdn.example.com;

    ssl_certificate     /etc/nginx/ssl/cdn.crt;
    ssl_certificate_key /etc/nginx/ssl/cdn.key;

    location / {
        proxy_pass https://edge_pool;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 5.4 Envoy Configuration for Streaming

```yaml
# envoy.yaml
static_resources:
  listeners:
  - name: streaming_listener
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 443
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: streaming_lb
          codec_type: AUTO
          route_config:
            name: streaming_routes
            virtual_hosts:
            - name: cdn
              domains: ["cdn.example.com"]
              routes:
              - match: { path_suffix: ".m3u8" }
                route:
                  cluster: edge_manifest
                  timeout: 10s
              - match: { path_suffix: ".mpd" }
                route:
                  cluster: edge_manifest
                  timeout: 10s
              - match: { path_suffix: ".ts" }
                route:
                  cluster: edge_segments
                  timeout: 60s
              - match: { path_suffix: ".m4s" }
                route:
                  cluster: edge_segments
                  timeout: 60s
          http_filters:
          - name: envoy.filters.http.router

  clusters:
  - name: edge_manifest
    connect_timeout: 2s
    type: STRICT_DNS
    lb_policy: LEAST_REQUEST
    health_checks:
    - timeout: 2s
      interval: 5s
      unhealthy_threshold: 3
      healthy_threshold: 2
      http_health_check:
        path: /healthz
    load_assignment:
      cluster_name: edge_manifest
      endpoints:
      - lb_endpoints:
        - endpoint: { address: { socket_address: { address: edge1, port_value: 443 }}}
        - endpoint: { address: { socket_address: { address: edge2, port_value: 443 }}}
        - endpoint: { address: { socket_address: { address: edge3, port_value: 443 }}}

  - name: edge_segments
    connect_timeout: 2s
    type: STRICT_DNS
    lb_policy: RING_HASH       # Consistent hashing for cache affinity
    ring_hash_lb_config:
      minimum_ring_size: 65536
    health_checks:
    - timeout: 2s
      interval: 5s
      unhealthy_threshold: 3
      healthy_threshold: 2
      http_health_check:
        path: /healthz
    load_assignment:
      cluster_name: edge_segments
      endpoints:
      - lb_endpoints:
        - endpoint: { address: { socket_address: { address: edge1, port_value: 443 }}}
        - endpoint: { address: { socket_address: { address: edge2, port_value: 443 }}}
        - endpoint: { address: { socket_address: { address: edge3, port_value: 443 }}}
```

### 5.5 Session Persistence Considerations

#### When Session Persistence Matters

For HLS/DASH streaming, session persistence (sticky sessions) is less critical than for stateful applications because:
- Each segment is an independent HTTP request
- Players handle reconnection automatically
- Content is cacheable at any edge

**However, session persistence IS important for:**
- WebRTC connections (stateful, long-lived)
- RTMP push/pull (stateful)
- Analytics accuracy (tracking which server served which viewer)
- Log aggregation (keeping a session's logs together)

#### HAProxy Session Persistence

```haproxy
backend edge_servers
    balance leastconn
    cookie SERVERID insert indirect nocache
    server edge1 10.0.1.10:443 cookie edge1 ssl verify none
    server edge2 10.0.1.11:443 cookie edge2 ssl verify none
```

#### Envoy Consistent Hashing

```yaml
# Route segment requests to the same edge based on URI
# This maximizes cache hit ratio by sending the same content to the same server
route:
  cluster: edge_segments
  hash_policy:
  - header:
      header_name: ":path"
```

### 5.6 Connection Draining for Rolling Updates

#### HAProxy

```haproxy
# Graceful shutdown: server enters draining mode
# Existing connections complete, new connections go elsewhere
server edge1 10.0.1.10:443 ssl verify none state draining
```

Or via the runtime API:

```bash
echo "set server edge_servers/edge1 state draining" | socat stdio /var/run/haproxy.sock
```

#### Nginx (with Plus or manual approach)

```bash
# Manual draining: mark server as down in upstream
# nginx waits for existing connections to complete before removing
# Requires nginx Plus or third-party module for graceful draining

# With open-source nginx, use the "backup" approach:
# 1. Remove server from upstream config
# 2. Reload nginx (graceful, no connection drop)
# 3. Existing requests complete on old workers
nginx -s reload
```

#### Envoy

```yaml
# Drain connections gracefully before removing
common_http_protocol_options:
  idle_timeout: 300s
# Envoy's health check fail will drain:
# When a health check fails, Envoy sets the host to "draining" state
# Existing streams complete; new streams avoid the host
```

### 5.7 Rate Limiting Strategies

#### Per-IP Rate Limiting (Nginx)

```nginx
# Define rate limit zones
limit_req_zone $binary_remote_addr zone=manifest_limit:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=segment_limit:10m rate=60r/s;
limit_conn_zone $binary_remote_addr zone=conn_limit:10m;

server {
    # Manifest: max 10 requests/sec per IP
    location ~ \.(m3u8|mpd)$ {
        limit_req zone=manifest_limit burst=20 nodelay;
        limit_req_status 429;
    }

    # Segments: max 60 requests/sec per IP
    # (1080p HLS with 2s segments = ~4 streams simultaneously at 60r/s)
    location ~ \.(ts|m4s)$ {
        limit_req zone=segment_limit burst=100 nodelay;
        limit_req_status 429;
    }

    # Concurrent connections per IP
    limit_conn conn_limit 50;
}
```

#### Per-Token Rate Limiting (for authenticated streams)

```nginx
# Rate limit by auth token (query param or header)
limit_req_zone $arg_token zone=token_limit:10m rate=5r/s;

location /live/ {
    limit_req zone=token_limit burst=10 nodelay;
    # Each unique token can only request 5 segments/sec
    # Prevents token sharing / password redistribution
}
```

#### Per-Stream Rate Limiting (bandwidth throttling)

```nginx
# Limit download speed per connection
location /download/ {
    limit_rate 10m;    # 10 MB/s = 80 Mbps per connection
    # Prevents a single client from consuming all bandwidth
}
```

### 5.8 DDoS Protection for Streaming Endpoints

#### Layered Defense

```
Layer 1: Upstream / ISP
    |   Null routing, scrubbing center
    |
Layer 2: Edge Network
    |   ACLs, SYN cookies, connection limits
    |
Layer 3: Load Balancer (HAProxy/Nginx)
    |   Rate limiting, connection caps
    |
Layer 4: Application (Nginx edge cache)
    |   URL-based rate limits, token validation
    |
Layer 5: Origin
    |   Shielded by all above layers
```

#### Nginx DDoS Configuration

```nginx
# Connection limits
limit_conn_zone $binary_remote_addr zone=addr:10m;
limit_conn addr 100;           # Max 100 concurrent connections per IP

# Request rate limits
limit_req_zone $binary_remote_addr zone=general:10m rate=30r/s;
limit_req zone=general burst=60 nodelay;

# Mitigate slowloris
client_body_timeout 10s;
client_header_timeout 10s;
send_timeout 10s;
keepalive_timeout 30s;

# Close connections with bad behavior
reset_timedout_connection on;

# Block known bad user agents
if ($http_user_agent ~* (python-requests|masscan|zgrab)) {
    return 403;
}

# SYN cookies (kernel level, not nginx)
# net.ipv4.tcp_syncookies = 1  (in sysctl.conf)
```

---

## 6. Bandwidth Cost Modeling

### 6.1 Bandwidth Pricing Models

#### Per-GB (Committed Volume)

Pay for actual data transferred. Most common for cloud CDN services.

| Volume / Month | Typical Price/GB | Provider Examples |
|---------------|-----------------|-------------------|
| < 10 TB | $0.04 - $0.12 | CloudFront, Azure CDN, Cloudflare |
| 10 - 100 TB | $0.02 - $0.06 | Volume discounts |
| 100 TB - 1 PB | $0.005 - $0.02 | BlazingCDN, negotiated contracts |
| > 1 PB | $0.002 - $0.01 | Deep enterprise discounts |

#### 95th Percentile (Committed Bandwidth)

Pay for sustained bandwidth, not total bytes. Common for colocation and transit.

**How it works:**
1. Measure bandwidth (Mbps or Gbps) every 5 minutes throughout the month
2. Sort all measurements from highest to lowest
3. Discard the top 5% (approximately 36 hours per month)
4. The highest remaining measurement is your billable rate

**When it benefits you:** Steady, predictable traffic (24/7 streaming channels, always-on IPTV)

**When it hurts:** Spiky traffic (live events, game launches). The 95th percentile captures your peak and you pay for it all month.

#### Transit vs IX Pricing

| Cost Type | Typical Rate | Notes |
|-----------|-------------|-------|
| IP Transit (100G committed) | $0.05 - $0.15/Mbps/month | Declining ~12% annually |
| IP Transit (10G committed) | $0.15 - $0.50/Mbps/month | Higher per-unit cost |
| IX Peering (settlement-free) | $0/GB (just port fee) | Port: $300-800/month for 1G |
| IX Peering (paid) | $0.001 - $0.005/GB | Rare; usually settlement-free |

### 6.2 Cost Per Viewer Per Hour

#### Bandwidth Consumption by Quality

| Quality Level | Bitrate (Mbps) | GB per Viewer-Hour |
|--------------|----------------|-------------------|
| 360p | 1.0 | 0.45 GB |
| 480p | 2.5 | 1.125 GB |
| 720p | 5.0 | 2.25 GB |
| 1080p | 8.0 | 3.6 GB |
| 1080p (high) | 12.0 | 5.4 GB |
| 4K | 25.0 | 11.25 GB |

*Formula: GB/hour = bitrate (Mbps) * 3600 (seconds) / 8 (bits to bytes) / 1024 (MB to GB)*

#### Cost Per Viewer-Hour (Cloud CDN at $0.02/GB)

| Quality | GB/hour | Cost/Viewer-Hour |
|---------|---------|-----------------|
| 720p | 2.25 GB | $0.045 |
| 1080p | 3.6 GB | $0.072 |
| 4K | 11.25 GB | $0.225 |

#### Cost Per Viewer-Hour (Self-Hosted with IX Peering)

Assuming fixed IX port cost of $500/month for 10G port:

| Concurrent Viewers at 720p | BW Used | Effective Cost/GB | Cost/Viewer-Hour |
|---------------------------|---------|-------------------|-----------------|
| 100 | 500 Mbps | $0.0005/GB | $0.001 |
| 1,000 | 5 Gbps | $0.0001/GB | $0.0002 |
| 5,000 | 25 Gbps | $0.0001/GB | $0.0002 |

Self-hosted is 20-100x cheaper per GB than cloud CDN at scale, but requires upfront hardware investment and operational overhead.

### 6.3 Storage Costs

| Storage Type | Cost/TB/Month | Use Case |
|-------------|--------------|----------|
| NVMe SSD (owned) | $8-15 (amortized over 3 years) | Edge cache, hot segments |
| HDD (owned) | $3-6 (amortized over 5 years) | Origin storage, VOD library |
| Object Storage (MinIO self-hosted) | $5-10/TB/month (hardware) | Origin storage, scalable |
| S3-compatible (cloud) | $20-23/TB/month | Backup, overflow |
| Cloud CDN origin storage | $0.023/GB/month (S3 Standard) | Small scale, convenience |

**Storage sizing for a streaming edge:**
- Live content: 10-50 GB per PoP (only recent segments are cached)
- VOD with 100 titles averaging 2 GB each: 200 GB per PoP (if caching full catalog)
- VOD with 10,000 titles: Use origin-shield model; edge caches only popular content

### 6.4 Transfer Cost Optimization

1. **Peering over transit:** At scale, peering at IXPs reduces transfer cost to near-zero. A single 10G port at an IXP (~$500/month) replaces $15,000+ in transit costs.

2. **Aggressive caching:** Every 1% improvement in cache hit ratio reduces origin egress. For a 10 Gbps stream, going from 90% to 95% hit ratio saves 500 Mbps of origin egress.

3. **Compression:** Apply gzip/brotli to manifests (text-based, highly compressible). Do NOT compress video segments (already compressed by video codec).

```nginx
gzip on;
gzip_types application/vnd.apple.mpegurl application/dash+xml application/json;
gzip_min_length 256;
gzip_comp_level 6;
# Do NOT add video/mp2t or video/mp4 to gzip_types
```

4. **Segment duration optimization:** Longer segments (10s vs 2s) mean fewer manifest updates and fewer HTTP requests. Fewer requests = less overhead. Tradeoff: higher latency.

5. **Token-based authentication at edge:** Validate tokens at the edge (Lua or nginx JS) rather than proxying to origin for auth. Eliminates auth-related origin traffic.

### 6.5 ROI Calculation: Edge Hardware vs Cloud CDN

#### Scenario: 5,000 concurrent viewers at 720p (5 Mbps average)

**Cloud CDN approach:**
- Bandwidth: 5,000 * 5 Mbps = 25 Gbps sustained
- Monthly transfer: 25 Gbps * 3600 * 730 / 8 / 1024 = ~8,100 TB/month
- At $0.02/GB: $162,000/month

**Self-hosted approach (3 PoPs):**

| Component | Cost | Notes |
|-----------|------|-------|
| 3x Edge servers (owned) | $15,000 one-time | 16-core, 64GB RAM, 2TB NVMe each |
| 1x Origin server (owned) | $10,000 one-time | 32-core, 128GB RAM, 20TB HDD + 2TB NVMe |
| Colocation (3 PoPs) | $3,000/month | Power, cooling, rack space |
| IX peering (3 ports, 10G each) | $1,500/month | ~$500/port |
| Transit (overflow) | $500/month | For networks not reachable via peering |
| GeoDNS service | $100/month | |
| Operational labor | ~20 hours/month | Monitoring, maintenance, patches |
| **Total monthly** | **~$5,600** | vs. $162,000 for cloud CDN |
| **Break-even** | **~5 months** | Hardware pays for itself in 5 months |

Even at much smaller scale (500 concurrent viewers), self-hosting with a single PoP costs approximately $1,500/month vs. $16,200/month for cloud CDN -- a 10x cost advantage.

### 6.6 Real-World Cost Examples

#### Example 1: 1,000 Concurrent Viewers at 5 Mbps (720p)

| Cost Factor | Cloud CDN | Self-Hosted (2 PoPs) |
|------------|-----------|----------------------|
| Bandwidth needed | 5 Gbps | 5 Gbps |
| Monthly transfer | ~1,620 TB | ~1,620 TB |
| Bandwidth cost | $32,400 ($0.02/GB) | $2,000 (colocation + peering) |
| Origin/shield cost | $200 (compute) | $5,000 one-time (hardware) |
| Storage (100 TB VOD) | $2,300 (S3) | $500 (HDD, amortized) |
| DNS + monitoring | $100 | $200 |
| **Monthly total** | **~$35,000** | **~$2,700** |

#### Example 2: 10,000 Concurrent Viewers at 5 Mbps

| Cost Factor | Cloud CDN | Self-Hosted (5 PoPs) |
|------------|-----------|----------------------|
| Bandwidth needed | 50 Gbps | 50 Gbps |
| Monthly transfer | ~16,200 TB | ~16,200 TB |
| Bandwidth cost | $324,000 ($0.02/GB) | $8,000 (colocation + peering) |
| Hardware (amortized monthly) | N/A | $2,000 (servers over 3 years) |
| Operational cost | Included | ~$3,000 (labor + tools) |
| **Monthly total** | **~$324,000** | **~$13,000** |

#### Example 3: 100,000 Concurrent Viewers at 5 Mbps

| Cost Factor | Cloud CDN | Self-Hosted (15 PoPs) |
|------------|-----------|----------------------|
| Bandwidth needed | 500 Gbps | 500 Gbps |
| Monthly transfer | ~162,000 TB | ~162,000 TB |
| Cloud CDN at $0.01/GB (negotiated) | $1,620,000 | N/A |
| Self-hosted total | N/A | ~$80,000/month |

At this scale, even cloud CDN pricing at $0.01/GB (negotiated 1 PB+ rate) is 20x more expensive than self-hosted.

---

## 7. DNS-Based Geographic Routing

### 7.1 GeoDNS Providers

| Provider | Type | Pricing Model | Notes |
|----------|------|---------------|-------|
| Cloudflare | Managed | Included with DNS plans | Basic geo routing free |
| AWS Route 53 | Managed | $0.50-1.00 per million queries + latency-based routing fees | Tight integration with AWS |
| NS1 (IBM) | Managed | Query-based + feature tiers | Advanced filtering and feed-based routing |
| PowerDNS + GeoIP backend | Self-hosted | Server cost only | Full control, MaxMind DB required |
| CoreDNS + geoip plugin | Self-hosted | Server cost only | Kubernetes-native, plugin ecosystem |
| BIND + GeoIP patches | Self-hosted | Server cost only | Legacy, functional but not well-maintained |

### 7.2 Self-Hosted GeoDNS with PowerDNS

#### PowerDNS GeoIP Backend Configuration

```yaml
# /etc/powerdns/pdns.conf
launch=geoip
geoip-database-files=/usr/share/GeoIP/GeoLite2-Country.mmdb
geoip-zones-file=/etc/powerdns/geoip.yml
edns-subnet-processing=yes
```

```yaml
# /etc/powerdns/geoip.yml
---
domains:
- name: cdn.example.com
  ttl: 30
  records:
    # Default (any location not matched below)
    cdn.example.com:
      - soa: ns1.example.com admin.example.com 2026010101 7200 3600 604800 30
      - ns: ns1.example.com
      - ns: ns2.example.com
      - a: 203.0.113.10       # Default origin IP

    # North America -> US-East PoP
    us-east.cdn.example.com:
      - a: 198.51.100.10

    # Europe -> Amsterdam PoP
    eu-central.cdn.example.com:
      - a: 192.0.2.10

    # Asia -> Tokyo PoP
    ap-east.cdn.example.com:
      - a: 198.51.100.20

    # Geo-mapped records (by country)
    # United States
    cdn.example.com:
      - a:
          content: 198.51.100.10    # US-East PoP
          ttl: 30
          geoip:
            - country: US
    # Netherlands, Germany, United Kingdom, France
    cdn.example.com:
      - a:
          content: 192.0.2.10       # Amsterdam PoP
          ttl: 30
          geoip:
            - country: NL
            - country: DE
            - country: GB
            - country: FR
    # Japan, South Korea, Singapore
    cdn.example.com:
      - a:
          content: 198.51.100.20    # Tokyo PoP
          ttl: 30
          geoip:
            - country: JP
            - country: KR
            - country: SG
```

#### PowerDNS Lua Records (Advanced)

PowerDNS also supports Lua records for dynamic responses:

```lua
-- /etc/powerdns/geo-records.lua
-- Returns the nearest PoP IP based on client location

function getpoop()
    local country = geolocation_country()
    local region = geolocation_region()

    if country == "US" then
        if region == "CA" or region == "OR" or region == "WA" then
            return "198.51.100.15"   -- US-West PoP
        end
        return "198.51.100.10"       -- US-East PoP (default for US)
    end

    if country == "NL" or country == "DE" or country == "GB" or country == "FR" then
        return "192.0.2.10"          -- Amsterdam PoP
    end

    if country == "JP" or country == "KR" then
        return "198.51.100.20"       -- Tokyo PoP
    end

    -- Default: US-East
    return "198.51.100.10"
end
```

### 7.3 Self-Hosted GeoDNS with CoreDNS

#### CoreDNS with GeoIP Plugin

```yaml
# Corefile
.:53 {
    geoip /usr/share/GeoIP/GeoLite2-Country.mmdb

    template IN A cdn.example.com {
        match "cdn\\.example\\.com"
        answer "{{ .Name }} 30 IN A {{ geoIP }}"
    }

    forward . 8.8.8.8 1.1.1.1
    log
    errors
}
```

The geoip plugin adds geo data to the request context. You can use the `rewrite` or `template` plugin to return different IPs based on the client's country.

#### Deploying CoreDNS for GeoDNS (Kubernetes)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-geodns
  namespace: dns
data:
  Corefile: |
    .:53 {
        geoip /etc/geoip/GeoLite2-Country.mmdb
        file /etc/coredns/zones/cdn.example.com.db
        forward . 8.8.8.8 1.1.1.1
        log
        errors
        health
        ready
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns-geodns
  namespace: dns
spec:
  replicas: 3
  selector:
    matchLabels:
      app: coredns-geodns
  template:
    metadata:
      labels:
        app: coredns-geodns
    spec:
      containers:
      - name: coredns
        image: coredns/coredns:1.12.0
        ports:
        - containerPort: 53
          protocol: UDP
        - containerPort: 53
          protocol: TCP
        volumeMounts:
        - name: config
          mountPath: /etc/coredns
        - name: geoip
          mountPath: /etc/geoip
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
      volumes:
      - name: config
        configMap:
          name: coredns-geodns
      - name: geoip
        configMap:
          name: geoip-db
```

### 7.4 EDNS Client Subnet

#### Problem

When a recursive DNS resolver (e.g., Google's 8.8.8.8) queries your authoritative DNS on behalf of a client, your DNS server sees the resolver's IP, not the client's IP. This breaks geo-routing because the resolver may be in a different location than the client.

#### Solution

EDNS Client Subnet (ECS, RFC 7871) passes a truncated version of the client's IP to the authoritative DNS server. This enables accurate geo-routing even through recursive resolvers.

**Accuracy considerations:**
- Most ECS-enabled resolvers send only the first 3 octets of an IPv4 address (/24)
- IPv6 addresses may be truncated to /56 or /48
- Some resolvers strip ECS entirely (privacy)
- MaxMind GeoLite2 is accurate to city-level for ~80% of IPv4 addresses at the /24 level

**PowerDNS:** Enable with `edns-subnet-processing=yes`
**CoreDNS:** The geoip plugin automatically uses EDNS0 subnet when present.

#### Which Resolvers Support ECS

| Resolver | ECS Support | Notes |
|----------|-------------|-------|
| Google (8.8.8.8) | Yes | Truncated to /24 |
| Cloudflare (1.1.1.1) | No | Strips ECS for privacy |
| OpenDNS (208.67.222.222) | Yes | |
| Quad9 (9.9.9.9) | No | Privacy-focused |
| ISP resolvers | Varies | Most large ISPs support ECS |

### 7.5 Anycast vs DNS-Based Routing Tradeoffs

| Factor | Anycast | DNS-Based |
|--------|---------|-----------|
| Routing accuracy | BGP topology (network distance) | Geographic (physical distance) |
| Client visibility | Server sees client IP directly | Server may see resolver IP (mitigated by ECS) |
| Failover speed | 30-90s (BGP convergence) | TTL + cache (30-300s) |
| Operational complexity | High (BGP, ASN) | Medium (DNS config) |
| Cost | High (ASN, BGP-capable routers) | Low (DNS server) |
| Attack surface | Harder to DDoS (traffic naturally distributes) | Single DNS target for DDoS |
| Control | Coarse (BGP path selection) | Fine-grained (per-country, per-continent rules) |
| Best combined with | Health-based BGP withdrawal | Real-time health checking |

**Recommendation for self-hosted:** Start with DNS-based routing. Add anycast only when you have 10+ PoPs and your own ASN.

### 7.6 TTL Considerations for Failover Speed

| TTL | Failover Speed | DNS Query Load | Cache Efficiency |
|-----|---------------|----------------|-----------------|
| 10s | Very fast (~10-30s) | Very high | Low |
| 30s | Fast (~30-90s) | High | Moderate |
| 60s | Moderate (~1-3 min) | Moderate | Good |
| 300s | Slow (~5-15 min) | Low | High |

**Recommendation for streaming:**
- **Live events:** TTL of 30s. Fast failover matters more than DNS efficiency.
- **VOD:** TTL of 60-300s. Content is static; failover is less urgent.
- **Never set TTL below 10s.** Some resolvers enforce minimum TTLs.

---

## 8. Multicast vs Unicast Tradeoffs

### 8.1 Where Multicast Helps

Multicast is a network-level broadcast: one packet stream is delivered to many receivers simultaneously. The network replicates packets at branching points, so each link carries the stream only once regardless of viewer count.

**Multicast is ideal for:**

| Use Case | Description | Bandwidth Savings |
|----------|-------------|-------------------|
| IPTV (hotel, hospital, campus) | Fixed channel lineup to many TVs | 100-200x vs unicast |
| Corporate town halls | Same live stream to every desk | 50-500x |
| Digital signage | Same content to many displays | 100-1000x |
| Surveillance distribution | Same camera feed to multiple monitors | N-1x (N monitors) |
| Trading floor video | Same feeds to many traders | 20-50x |
| Education / lecture halls | Same lecture to many screens | 50-200x |

**Quantitative example:** Streaming a 6 Mbps channel to 200 viewers:
- Unicast: 200 * 6 Mbps = 1,200 Mbps (1.2 Gbps) on every shared link
- Multicast: 6 Mbps total on every link (regardless of viewer count)

### 8.2 Why Multicast Does Not Work Over the Public Internet

Multicast requires every router between the source and every receiver to support multicast routing (PIM) and group management (IGMP). The public internet does not meet this requirement:

1. **Most ISPs do not support multicast transit.** They would need to run PIM on every router and manage multicast state for every group. The operational overhead is massive.

2. **There is no business model.** Transit providers charge per bit. Multicast reduces bits. There is no incentive for them to enable it.

3. **Security concerns.** Multicast can be used for amplification attacks. ISPs explicitly block it at their borders.

4. **Last-mile limitations.** Most home routers and Wi-Fi access points do not forward multicast reliably. Even within a home network, multicast can cause Wi-Fi performance issues.

**Bottom line:** Multicast only works within networks you control (LAN, WAN, campus, datacenter). It cannot traverse the public internet.

### 8.3 Multicast-to-Unicast Conversion at Edge

For scenarios where you need to bridge a multicast source to unicast clients:

```
Multicast Source (e.g., IPTV headend)
    |
    | (multicast, e.g., udp://239.1.1.1:5000)
    |
Multicast-to-Unicast Gateway
    |   (receives multicast, serves as HLS/DASH origin)
    |
    | (unicast HTTP)
    |
CDN Edge / Load Balancer
    |
    | (unicast HTTP)
    |
Internet Viewers
```

#### Implementation with FFmpeg

```bash
# Receive multicast stream and re-package as HLS for unicast delivery
ffmpeg \
    -i "udp://239.1.1.1:5000?fifo_size=5000000" \
    -c:v copy \
    -c:a copy \
    -f hls \
    -hls_time 4 \
    -hls_list_size 6 \
    -hls_flags delete_segments \
    -hls_segment_filename "/var/www/stream/segment_%05d.ts" \
    "/var/www/stream/manifest.m3u8"
```

#### Implementation with nginx + MPEG-TS module

```nginx
# nginx.conf - receive MPEG-TS over multicast, output HLS
stream {
    server {
        listen 5000 udp;

        # Receive multicast stream
        # (requires nginx MPEG-TS module)
        exec_static ffmpeg -i udp://239.1.1.1:5000 -c copy -f hls \
            -hls_time 4 -hls_list_size 6 \
            /var/cache/nginx/hls/stream.m3u8;
    }
}
```

### 8.4 Multicast Routing Fundamentals

#### IGMP (Internet Group Management Protocol)

IGMP operates between hosts and their directly-connected router. It tells the router which multicast groups the hosts want to receive.

| Version | Capability | Notes |
|---------|-----------|-------|
| IGMPv1 | Join group, no leave | Obsolete |
| IGMPv2 | Join + leave | Basic, widely supported |
| IGMPv3 | Join + leave + source filtering | Modern; allows SSM (Source-Specific Multicast) |

**IGMP Snooping:** Switches listen to IGMP messages to learn which ports have group members. Without IGMP snooping, multicast floods to all ports (like broadcast). With IGMP snooping, multicast only goes to ports that have requested it.

```
Switch with IGMP Snooping:
    Port 1: Receiver A (joined 239.1.1.1) -> gets stream
    Port 2: Receiver B (joined 239.1.1.1) -> gets stream
    Port 3: Receiver C (no join)           -> does NOT get stream
    Port 4: Source (239.1.1.1)             -> sends stream
```

#### PIM (Protocol Independent Multicast)

PIM routes multicast traffic between subnets. It builds a multicast distribution tree.

| Mode | Full Name | Tree Type | Use Case |
|------|-----------|-----------|----------|
| PIM-SM | Sparse Mode | Shared tree (RP-based) then shortest-path tree | Receivers are scattered; most networks |
| PIM-DM | Dense Mode | Source-based tree (flood and prune) | Receivers are everywhere; rarely used |
| PIM-SSM | Source-Specific | Source-based tree | Known source; most efficient for streaming |

**PIM-SM with Rendezvous Point (RP):**
1. Receivers join via IGMP to their local router
2. Local router sends PIM Join toward the RP
3. Source registers with the RP
4. RP builds the distribution tree from source to receivers
5. After initial setup, routers may switch to shortest-path tree for efficiency

**PIM-SSM (recommended for streaming):**
- Uses the range 232.0.0.0/8
- No RP needed
- Receivers specify both the group AND the source
- Most efficient: traffic follows the shortest path from source to each receiver

```bash
# Linux PIM configuration (using pimd or FRRouting)
# /etc/frr/daemons
pimd=yes

# /etc/frr/frr.conf
router pim
  ! Define the RP (if using PIM-SM)
  rp-address 10.0.0.1

interface eth0
  ip pim
  ip igmp

interface eth1
  ip pim
  ip igmp
```

### 8.5 Simulcast vs Multicast for Internal Corporate Streaming

#### Simulcast (Unicast to Multiple Qualities)

The encoder outputs multiple bitrate streams simultaneously, each delivered via unicast HTTP/HLS. Viewers select their quality based on available bandwidth (adaptive bitrate streaming).

**Advantages:**
- Works on any network (no multicast requirement)
- Adaptive bitrate support
- VOD / DVR / time-shift support
- Works over Wi-Fi and VPN

**Disadvantages:**
- Bandwidth scales linearly with viewer count
- Higher server load

#### Multicast (Single Stream to Many)

The encoder outputs one stream to a multicast group. All receivers get the same stream.

**Advantages:**
- Bandwidth is constant regardless of viewer count
- Zero server load per viewer (network handles distribution)
- Lowest possible latency (no HTTP overhead)

**Disadvantages:**
- No adaptive bitrate (one quality for everyone)
- No VOD / time-shift / rewind
- Requires multicast-capable network (rare outside controlled environments)
- No per-viewer analytics

#### Hybrid Approach (Recommended for Corporate)

```
Encoder
    |
    +---> Multicast (same stream, 1080p, to desk phones / IPTV)
    |
    +---> HLS/DASH origin (ABR ladder, for web browsers / mobile / VPN users)
              |
              +---> Internal CDN / Load Balancer
                        |
                        +---> Unicast HTTP to browser/mobile viewers
```

1. Multicast the primary stream to IPTV endpoints (lobby displays, conference rooms, desk phones)
2. Simultaneously encode to HLS/DASH for web and mobile viewers
3. Use the same encoder (e.g., FFmpeg, OBS, hardware encoder) to output both streams

```bash
# FFmpeg: output multicast + HLS simultaneously
ffmpeg \
    -i "rtmp://encoder.example.com/live/stream" \
    -c:v libx264 -b:v 8M -s 1920x1080 \
    -c:a aac -b:a 128k \
    -f mpegts "udp://239.1.1.1:5000?pkt_size=1316" \
    \
    -c:v libx264 -b:v 8M -s 1920x1080 \
    -c:a aac -b:a 128k \
    -f hls -hls_time 4 -hls_list_size 6 \
    -hls_segment_filename "/var/www/hls/high/seg_%05d.ts" \
    "/var/www/hls/high/manifest.m3u8" \
    \
    -c:v libx264 -b:v 3M -s 1280x720 \
    -c:a aac -b:a 96k \
    -f hls -hls_time 4 -hls_list_size 6 \
    -hls_segment_filename "/var/www/hls/med/seg_%05d.ts" \
    "/var/www/hls/med/manifest.m3u8" \
    \
    -c:v libx264 -b:v 1M -s 854x480 \
    -c:a aac -b:a 64k \
    -f hls -hls_time 4 -hls_list_size 6 \
    -hls_segment_filename "/var/www/hls/low/seg_%05d.ts" \
    "/var/www/hls/low/manifest.m3u8"
```

---

## Appendix A: Quick-Reference Configuration Templates

### Minimal Edge Cache (Single PoP)

```nginx
proxy_cache_path /var/cache/nginx/edge
    levels=1:2 keys_zone=edge:256m max_size=200g inactive=24h;

server {
    listen 443 ssl http2;
    server_name cdn.example.com;

    location /live/ {
        proxy_pass http://origin.internal;
        proxy_cache edge;
        proxy_cache_lock on;
        proxy_cache_use_stale updating error timeout;

        location ~ \.m3u8$ {
            proxy_cache_valid 200 2s;
            add_header Cache-Control "public, max-age=2, stale-while-revalidate=5";
        }
        location ~ \.(ts|m4s)$ {
            proxy_cache_valid 200 48h;
            add_header Cache-Control "public, max-age=172800, immutable";
        }
    }

    location /vod/ {
        proxy_pass http://origin.internal;
        proxy_cache edge;

        location ~ \.(m3u8|mpd)$ {
            proxy_cache_valid 200 5m;
        }
        location ~ \.(ts|m4s|mp4)$ {
            proxy_cache_valid 200 30d;
        }
    }
}
```

### Full Production Edge with Rate Limiting and DDoS Protection

```nginx
# Rate limit zones
limit_req_zone $binary_remote_addr zone=manifest:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=segment:10m  rate=60r/s;
limit_conn_zone $binary_remote_addr zone=connections:10m;

# Cache zones
proxy_cache_path /var/cache/nginx/manifests
    levels=1:2 keys_zone=manifests:64m max_size=10g inactive=60s;
proxy_cache_path /var/cache/nginx/segments
    levels=1:2 keys_zone=segments:512m max_size=500g inactive=48h;

upstream origin_shield {
    server shield.internal:443;
    keepalive 64;
}

server {
    listen 443 ssl http2;
    server_name cdn.example.com;

    # Global limits
    limit_conn connections 100;
    client_body_timeout 10s;
    client_header_timeout 10s;

    # CORS
    add_header Access-Control-Allow-Origin "*";
    add_header Access-Control-Allow-Methods "GET, OPTIONS";

    # Manifests
    location ~ \.(m3u8|mpd)$ {
        limit_req zone=manifest burst=20 nodelay;

        proxy_pass https://origin_shield;
        proxy_cache manifests;
        proxy_cache_valid 200 2s;
        proxy_cache_lock on;
        proxy_cache_use_stale updating error timeout;
        proxy_cache_background_update on;

        add_header Cache-Control "public, max-age=2, stale-while-revalidate=5, stale-if-error=300";
        add_header X-Cache-Status $upstream_cache_status;
    }

    # Segments
    location ~ \.(ts|m4s|init\.mp4)$ {
        limit_req zone=segment burst=100 nodelay;

        proxy_pass https://origin_shield;
        proxy_cache segments;
        proxy_cache_valid 200 48h;
        proxy_cache_lock on;

        add_header Cache-Control "public, max-age=172800, immutable";
        add_header X-Cache-Status $upstream_cache_status;
    }

    # Health check
    location /healthz {
        return 200 "ok\n";
        access_log off;
    }

    # Block bad bots
    if ($http_user_agent ~* (python-requests|masscan|zgrab|nikto)) {
        return 403;
    }
}
```

## Appendix B: Kernel Tuning for High-Traffic Streaming Edges

```bash
# /etc/sysctl.d/99-streaming-cdn.conf

# Connection handling
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15

# Keepalive
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 5

# Buffer sizes
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# TCP optimization
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_syncookies = 1

# File descriptors
fs.file-max = 2097152

# Connection tracking (if using conntrack)
net.netfilter.nf_conntrack_max = 1048576
net.netfilter.nf_conntrack_tcp_timeout_established = 7200
```

```bash
# /etc/security/limits.d/99-streaming-cdn.conf
# Raise file descriptor limits for nginx
nginx soft nofile 1048576
nginx hard nofile 1048576
root  soft nofile 1048576
root  hard nofile 1048576
```

## Appendix C: Monitoring Metrics

### Key Metrics to Collect

| Metric | Source | Alert Threshold |
|--------|--------|----------------|
| Cache hit ratio (per zone) | nginx stub_status + custom log | < 80% for segments |
| Requests per second | nginx stub_status | > 80% of tested max |
| Bandwidth (in/out) | node_network | > 85% of uplink |
| Disk usage (cache partition) | node_filesystem | > 90% |
| TTFB (p50, p95, p99) | nginx log analysis | p99 > 500ms |
| Origin request rate | nginx upstream metrics | Spike above baseline |
| 4xx/5xx error rate | nginx log analysis | > 1% of requests |
| Active connections | nginx stub_status | > 80% of worker_connections |
| Per-PoP latency (synthetic probes) | Blackbox exporter | > 100ms |
| DNS query latency | PowerDNS/CoreDNS metrics | > 50ms |

### Prometheus Metrics from Nginx

```nginx
# Enable stub_status for Prometheus scraping
location /nginx_status {
    stub_status;
    access_log off;
    allow 10.0.0.0/8;
    deny all;
}
```

```yaml
# prometheus.yml scrape config
scrape_configs:
  - job_name: 'cdn-edge'
    static_configs:
      - targets:
        - 'edge-us-east:9113'   # nginx-prometheus-exporter
        - 'edge-us-west:9113'
        - 'edge-eu-central:9113'
    metrics_path: /metrics
```

---

## Appendix D: Glossary

| Term | Definition |
|------|-----------|
| ABR | Adaptive Bitrate Streaming -- player adjusts quality based on available bandwidth |
| BGP | Border Gateway Protocol -- routing protocol of the internet |
| CDNI | CDN Interconnection -- IETF standard for CDN peering |
| DASH | Dynamic Adaptive Streaming over HTTP -- ISO standard adaptive streaming |
| ECS | EDNS Client Subnet -- DNS extension that passes client IP info |
| ETag | Entity Tag -- HTTP header for conditional requests and cache validation |
| GeoDNS | DNS server that returns different IPs based on client geography |
| HLS | HTTP Live Streaming -- Apple's adaptive streaming protocol |
| IGMP | Internet Group Management Protocol -- manages multicast group membership |
| IXP | Internet Exchange Point -- physical infrastructure where networks interconnect |
| LL-HLS | Low-Latency HLS -- Apple extension for sub-3-second streaming |
| LL-DASH | Low-Latency DASH -- DASH extension for low-latency delivery |
| PIM | Protocol Independent Multicast -- multicast routing protocol |
| PoP | Point of Presence -- edge server location |
| RP | Rendezvous Point -- central point in PIM-SM multicast |
| SSM | Source-Specific Multicast -- multicast where receiver knows the source |
| TTL | Time to Live -- how long a cached response is considered fresh |

---

*Sources and further reading:*

- [How to Use CDN for Video Streaming](https://oneuptime.com/blog/post/2026-01-28-cdn-video-streaming/view)
- [Achieving 3-Second Latency in Streaming: LL-HLS and LL-DASH Optimization with CDN](https://gcore.com/blog/optimizing-hls-dash-3sec)
- [Streaming CDN Architecture for Low-Latency Delivery](https://blog.blazingcdn.com/en-us/streaming-cdn-architecture-low-latency-delivery)
- [How to Implement BGP Anycast for DNS or CDN Load Distribution](https://oneuptime.com/blog/post/2026-03-20-bgp-anycast-dns-cdn-load-distribution/view)
- [Building an Open Source Anycast CDN (APNIC Blog)](https://blog.apnic.net/2021/04/07/building-an-open-source-anycast-cdn/)
- [How CDNs Route Users: DNS, Geo Routing, and Anycast](https://medium.com/@jevinmorad/how-cdns-route-users-dns-geo-routing-and-anycast-677bc300d159)
- [CDN Price Benchmark: Comparing 12 Providers](https://blog.blazingcdn.com/en-us/cdn-price-benchmark-comparing-12-providers-by-gb-served)
- [Streaming CDN Pricing Guide](https://blog.blazingcdn.com/en-us/streaming-cdn-pricing-guide-bandwidth-storage-cost-factors)
- [IP Transit Pricing in 2025 (Telegeography)](https://resources.telegeography.com/ip-transit-price-erosion-significant-regional-differences-remain)
- [DrPeering Internet Transit Prices Historical and Projections](https://drpeering.net/white-papers/Internet-Transit-Pricing-Historical-And-Projected.php)
- [IP Transit vs Peering (Kentik)](https://www.kentik.com/kentipedia/ip-transit-vs-peering/)
- [Multi-CDN Strategy: Benefits and Best Practices](https://www.ioriver.io/blog/multi-cdn-strategy)
- [Multi-CDN Load Balancing: Real-Time Failover](https://blog.blazingcdn.com/en-us/multi-cdn-load-balancing-real-time-failover-dns-anycast)
- [Nginx Rate Limiting and DDoS Protection](https://www.virtua.cloud/learn/en/tutorials/nginx-rate-limiting-ddos-protection)
- [NGINX Rate Limiting: Complete Guide (2026)](https://www.getpagespeed.com/server-setup/nginx/nginx-rate-limiting)
- [CoreDNS GeoIP Plugin](https://coredns.io/plugins/geoip/)
- [PowerDNS GeoIP Backend](https://doc.powerdns.com/authoritative/backends/geoip.html)
- [Edge CDN PoP Placement and Global Traffic Steering](https://blog.blazingcdn.com/en-us/edge-cdn-pop-placement-global-traffic-steering)
- [CDN Server Placement Strategy](https://blog.blazingcdn.com/en-us/cdn-server-placement-strategy-reducing-latency-worldwide)
- [Nginx Caching Guide (Official)](https://blog.nginx.org/blog/nginx-caching-guide)
- [Smart and Efficient Byte-Range Caching with NGINX](https://blog.nginx.org/blog/smart-efficient-byte-range-caching-nginx)
- [Unified Streaming: Origin Shield Cache](https://docs.unified-streaming.com/best-practice/caching/recommendations/shield-cache.html)
- [IPTV Multicast vs Unicast Explained](https://www.justrays.com/iptv-multicast-vs-unicast-explained-bandwidth-igmp-and-real-world-deployments/)
- [Implementing Multicast IPTV with IGMP and PIM](https://zoliptv.com/blog/implementing-multicast-iptv-with-igmp-and-pim-protocols)
- [Fastly Streaming Configuration Guidelines](https://www.fastly.com/documentation/guides/full-site-delivery/video/streaming-configuration-guidelines/)
- [How CDNs Use Edge Caching and Global PoPs](https://www.techtimes.com/articles/316272/20260501/how-cdns-use-edge-caching-global-pops-lower-latency-smoother-streaming.htm)
