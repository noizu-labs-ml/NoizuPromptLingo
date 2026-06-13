# fstab-mounter — Project Layout

```
fstab-mounter/
├── fstab-remount                          # Main script — parses osx-fstab, mounts volumes
├── com.keithbrings.fstab-remount.plist    # LaunchDaemon plist — runs script at boot
├── osx-fstab.stub                         # Config template — installed to /etc/osx-fstab
├── Makefile                               # install / uninstall / status / logs
└── docs/
    ├── PROJ-ARCH.md                       # Architecture overview
    ├── PROJ-ARCH.summary.md               # Architecture quick reference
    ├── PROJ-LAYOUT.md                     # This file
    └── PROJ-LAYOUT.summary.md             # Layout quick reference
```

## Installed Locations

| Source | Installed To | Owner |
|--------|-------------|-------|
| `fstab-remount` | `/usr/local/bin/fstab-remount` | root (mode 755) |
| `com.keithbrings.fstab-remount.plist` | `/Library/LaunchDaemons/` | root (mode 644) |
| `osx-fstab.stub` | `/etc/osx-fstab` | root (mode 644, first install only) |

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `/etc/osx-fstab` | Edit after `make install` — add volume entries per the format in the stub |
