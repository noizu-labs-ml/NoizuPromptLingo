# LaunchAgents/LaunchDaemons for Background Processes

## Overview

LaunchAgents and LaunchDaemons are macOS mechanisms for automatically launching applications and services. For a clipboard manager, they enable background execution at system startup without requiring user intervention.

## Core Concepts

- **LaunchAgents**: Runs as user session, can display UI
- **LaunchDaemons**: Runs as root, no UI, system-wide
- **Property Lists (plists)**: XML configuration files
- **Launch Daemons**: System-level background services
- **RunAtLoad**: Immediate execution on load

## Key APIs and Frameworks

| API/Framework | Purpose |
|--------------|---------|
| `launchd` | System service manager |
| `launchctl` | CLI for launchd management |
| `Property List (.plist)` | Launch configuration |
| `ServiceManagement framework` | Modern API for services |
| `SMJobSubmit` | Sumbmit jobs to launchd |

## Property List Structure

### LaunchAgent Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Unique identifier -->
    <key>Label</key>
    <string>com.yourapp.clipboardmanager</string>

    <!-- Path to executable or app bundle -->
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/ClipboardManager.app/Contents/MacOS/ClipboardManager</string>
    </array>

    <!-- Start on boot/login -->
    <key>RunAtLoad</key>
    <true/>

    <!-- Keep alive if crashes -->
    <key>KeepAlive</key>
    <true/>

    <!-- Auto-restart on exit -->
    <key>ExitTimeOut</key>
    <integer>5</integer>

    <!-- Resource limits -->
    <key>LimitLoadToSessionType</key>
    <array>
        <string>Aqua</string>
    </array>

    <!-- Environment variables -->
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin</string>
        <key>HOME</key>
        <string>/Users/$(id -un)</string>
    </dict>

    <!-- Standard output logging -->
    <key>StandardOutPath</key>
    <string>/Users/$(id -un)/Library/Logs/ClipboardManager/launch.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/$(id -un)/Library/Logs/ClipboardManager/launch.err</string>

    <!-- Working directory -->
    <key>WorkingDirectory</key>
    <string>/Applications/ClipboardManager.app/Contents/MacOS</string>

    <!-- Nice value (lower = higher priority) -->
    <key>Nice</key>
    <integer>0</integer>

    <!-- Process type -->
    <key>ProcessType</key>
    <string>Interactive</string>

    <!-- Abort if crashing too frequently -->
    <key>ThrottleInterval</key>
    <integer>10</integer>

    <!-- Wait for network -->
    <key>WaitForNetwork</key>
    <false/>

    <!-- Disable automatically on errors -->
    <key>AbandonProcessGroup</key>
    <false/>
</dict>
</plist>
```

### LaunchDaemon Example (System-Level)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.yourapp.clipboardhelper</string>

    <key>ProgramArguments</key>
    <array>
        <string>/Library/Application Support/YourApp/ClipboardHelper</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
        <key>Crashed</key>
        <true/>
    </dict>

    <key>LimitLoadToSessionType</key>
    <array>
        <string>Aqua</string>
    </array>

    <!-- Run only if network is up -->
    <key>WaitForNetwork</key>
    <true/>

    <!-- Standard output logs -->
    <key>StandardOutPath</key>
    <string>/var/log/ClipboardHelper/launch.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/ClipboardHelper/launch.err</string>

    <!-- Privileges -->
    <key>UserName</key>
    <string>root</string>

    <key>GroupName</key>
    <string>wheel</string>

    <!-- Resource limits -->
    <key>ProcessType</key>
    <string>Background</string>

    <key>Nice</key>
    <integer>1</integer>
</dict>
</plist>
```

## Swift Code Examples

### LaunchAgent Installation

```swift
import Foundation
import ServiceManagement

class LaunchAgentManager {
    private let bundleID = "com.yourapp.clipboardmanager"
    private let agentName = "com.yourapp.clipboardmanager.plist"
    private let agentLabel = bundleID

    var agentURL: URL {
        let agentsPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents")
        return agentsPath.appendingPathComponent(agentName)
    }

    var isInstalled: Bool {
        // Check if file exists
        FileManager.default.fileExists(atPath: agentURL.path)
    }

    var isEnabled: Bool {
        var isRunning: Bool = false

        if #available(macOS 13.0, *) {
            isRunning = SMAppService.status(for: .loginItem) == .enabled
        } else {
            // Fallback for older macOS using launchctl
            isRunning = checkLegacyStatus()
        }

        return isRunning
    }

    private func checkLegacyStatus() -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        task.arguments = ["list", bundleID]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }

    func install() throws {
        // Ensure LaunchAgents directory exists
        let agentsPath = agentURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: agentsPath,
            withIntermediateDirectories: true,
            attributes: nil
        )

        // Generate plist
        let plist = generatePlist()

        // Write plist
        try plist.write(to: agentURL, atomically: true, encoding: .utf8)

        // Load agent
        try loadAgent()

        print("LaunchAgent installed at: \(agentURL.path)")
    }

    func uninstall() throws {
        // Unload agent
        try unloadAgent()

        // Remove plist file
        if FileManager.default.fileExists(atPath: agentURL.path) {
            try FileManager.default.removeItem(at: agentURL)
        }
    }

    func enable() throws {
        if #available(macOS 13.0, *) {
            // Modern API for macOS 13+
            let success = SMAppService.register(item: .loginItem)
            if !success {
                throw LaunchAgentError.failedToEnable
            }
        } else {
            // Legacy approach using launchctl bootstrap
            try enableLegacy()
        }
    }

    func disable() throws {
        if #available(macOS 13.0, *) {
            let success = SMAppService.unregister(item: .loginItem)
            if !success {
                throw LaunchAgentError.failedToDisable
            }
        } else {
            try disableLegacy()
        }
    }

    private func generatePlist() -> String {
        guard let bundlePath = Bundle.main.bundlePath as String? else {
            return ""
        }

        let logsPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/ClipboardManager").path

        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>\(bundleID)</string>

            <key>ProgramArguments</key>
            <array>
                <string>\(bundlePath)</string>
            </array>

            <key>RunAtLoad</key>
            <true/>

            <key>KeepAlive</key>
            <true/>

            <key>LimitLoadToSessionType</key>
            <array>
                <string>Aqua</string>
            </array>

            <key>WorkingDirectory</key>
            <string>\(bundlePath)</string>

            <key>StandardOutPath</key>
            <string>\(logsPath)/launch.log</string>

            <key>StandardErrorPath</key>
            <string>\(logsPath)/launch.err</string>

            <key>ProcessType</key>
            <string>Interactive</string>
        </dict>
        </plist>
        """
    }

    private func loadAgent() throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        task.arguments = ["load", "-w", agentURL.path]

        try task.run()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            throw LaunchAgentError.failedToLoad
        }
    }

    private func unloadAgent() throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        task.arguments = ["unload", "-w", agentURL.path]

        try task.run()
        task.waitUntilExit()

        // Ignore errors if agent wasn't loaded
    }

    @available(macOS, deprecated: 13.0, message: "Use SMAppService on macOS 13+")
    private func enableLegacy() throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        task.arguments = ["bootstrap", "gui/\(getUID())", agentURL.path]

        try task.run()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            throw LaunchAgentError.failedToEnable
        }
    }

    @available(macOS, deprecated: 13.0, message: "Use SMAppService on macOS 13+")
    private func disableLegacy() throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        task.arguments = ["bootout", "gui/\(getUID())", bundleID]

        try task.run()
        task.waitUntilExit()
        // Ignore errors if agent wasn't enabled
    }

    private func getUID() -> Int {
        // Get current user ID
        guard let uid = getuid() as Int32? else {
            return 501 // Default to first user
        }
        return Int(uid)
    }
}

enum LaunchAgentError: Error {
    case failedToLoad
    case failedToUnload
    case failedToEnable
    case failedToDisable
    case permissionDenied
}
```

### Service Management API (macOS 13+)

```swift
import Foundation
import ServiceManagement

@available(macOS 13.0, *)
class ModernLaunchAgentManager {
    private let bundleID = "com.yourapp.clipboardmanager"

    var isEnabled: Bool {
        SMAppService.status(for: .init(identifier: bundleID)) == .enabled
    }

    func enable() -> Bool {
        return SMAppService.register(item: .init(identifier: bundleID))
    }

    func disable() -> Bool {
        return SMAppService.unregister(item: .init(identifier: bundleID))
    }

    func uninstall() -> Bool {
        // Remove from login items
        return SMAppService.unregister(item: .init(identifier: bundleID))
    }
}
```

### Helper Tool Installation

```swift
import Foundation

class HelperToolInstaller {
    private let toolName = "ClipboardHelper"
    private let toolBundleID = "com.yourapp.clipboardhelper"
    private let destinationPath = "/Library/Application Support/YourApp/\(toolName)"

    func install() throws {
        guard let toolBundlePath = Bundle.main.path(forResource: toolName, ofType: nil) else {
            throw HelperToolError.toolNotFound
        }

        // Create destination directory
        let destination = destinationPath as NSString
        let destinationDir = destination.deletingLastPathComponent

        try FileManager.default.createDirectory(
            atPath: destinationDir,
            withIntermediateDirectories: true,
            attributes: nil
        )

        // Check if helper is already installed
        if FileManager.default.fileExists(atPath: destinationPath) {
            // Compare versions, install if newer
            if isCurrentToolNewer(than: destinationPath) {
                installTool(at: toolBundlePath, to: destinationPath)
            }
        } else {
            installTool(at: toolBundlePath, to: destinationPath)
        }

        // Set permissions (root:wheel 755)
        try setToolPermissions()

        // Install LaunchDaemon for helper
        try installHelperLaunchDaemon()
    }

    private func installTool(at source: String, to destination: String) {
        // Remove existing
        if FileManager.default.fileExists(atPath: destination) {
            try? FileManager.default.removeItem(atPath: destination)
        }

        // Copy helper with admin privileges
        do {
            try executeAsRoot(cmd: "/bin/cp", args: [source, destination])
        } catch {
            print("Failed to copy helper as root: \(error)")
            throw HelperToolError.installationFailed
        }
    }

    private func setToolPermissions() throws {
        // Set owner to root:wheel
        try executeAsRoot(cmd: "/usr/sbin/chown", args: ["root:wheel", destinationPath])

        // Set executable permissions
        try executeAsRoot(cmd: "/bin/chmod", args: ["755", destinationPath])
    }

    private func installHelperLaunchDaemon() throws {
        let plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>\(toolBundleID)</string>

            <key>ProgramArguments</key>
            <array>
                <string>\(destinationPath)</string>
            </array>

            <key>RunAtLoad</key>
            <true/>

            <key>KeepAlive</key>
            <true/>
        </dict>
        </plist>
        """

        let daemonPath = "/Library/LaunchDaemons/\(toolBundleID).plist"

        try executeAsRoot(cmd: "/bin/sh", args: [
            "-c",
            "echo '\(plistContent)' > \(daemonPath)"
        ])

        try executeAsRoot(cmd: "/bin/chmod", args: ["644", daemonPath])
        try executeAsRoot(cmd: "/bin/launchctl", args: ["load", "-w", daemonPath])
    }

    private func isCurrentToolNewer(than installedTool: String) -> Bool {
        guard let currentTool = Bundle.main.path(forResource: toolName, ofType: nil) else {
            return false
        }

        let currentVersion = getVersionOfFile(at: currentTool)
        let installedVersion = getVersionOfFile(at: installedTool)

        return currentVersion > installedVersion
    }

    private func getVersionOfFile(at path: String) -> Int {
        let attributes = try? FileManager.default.attributesOfItem(atPath: path)
        return attributes?[.modificationDate] as? Int ?? 0
    }

    private func executeAsRoot(cmd: String, args: [String]) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = [
            "-e",
            "do shell script \"\(cmd) \(args.joined(separator: " "))\" with administrator privileges"
        ]

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            throw HelperToolError.executionFailed
        }
    }

    func uninstall() throws {
        // Unload daemon
        try executeAsRoot(cmd: "/bin/launchctl", args: ["unload", "-w", "\(toolBundleID).plist"])

        // Remove daemon plist
        let daemonPath = "/Library/LaunchDaemons/\(toolBundleID).plist"
        try executeAsRoot(cmd: "/bin/rm", args: [daemonPath])

        // Remove helper tool
        try executeAsRoot(cmd: "/bin/rm", args: ["-rf", destinationPath])
    }
}

enum HelperToolError: Error {
    case toolNotFound
    case installationFailed
    case executionFailed
}
```

### LaunchAgent Status Monitoring

```swift
import Foundation

class LaunchAgentMonitor {
    private let timer: Timer
    private let interval: TimeInterval
    private let bundleID: String
    private var lastStatus: Bool = false
    private var onChange: ((Bool) -> Void)?

    init(bundleID: String, interval: TimeInterval = 5.0) {
        self.bundleID = bundleID
        self.interval = interval
        self.timer = Timer(timeInterval: interval, target: self, selector: #selector(checkStatus), userInfo: nil, repeats: true)
    }

    func monitor(callback: @escaping (Bool) -> Void) {
        onChange = callback
        checkStatus()
        RunLoop.main.add(timer, forMode: .commonModes)
    }

    func stop() {
        timer.invalidate()
    }

    @objc private func checkStatus() {
        let currentStatus = isAgentRunning

        if currentStatus != lastStatus {
            lastStatus = currentStatus
            onChange?(currentStatus)
        }
    }

    private var isAgentRunning: Bool {
        var isRunning = false

        // Check using launchctl
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        task.arguments = ["list", bundleID]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            isRunning = task.terminationStatus == 0
        } catch {
            isRunning = false
        }

        return isRunning
    }
}
```

## Implementation Considerations

### Agent vs Daemon Decision

| Factor | LaunchAgent | LaunchDaemon |
|--------|-------------|--------------|
| Runs as | User | System (root) |
| UI Access | Yes | No |
| Installation | ~/Library/LaunchAgents/ | /Library/LaunchDaemons/ |
| Permissions | User | Elevated |
| Auto-start | User login only | System boot |
| Best for | Apps with UI | Background services |

### Security Considerations

1. **Code Sign**: All helper tools must be code-signed
2. **Validate**: Verify helper integrity before use
3. **Privilege Escalation**: Use Authorization Services for admin tasks
4. **Sandbox**: Both agent and daemon must consider sandbox

### Error Recovery

Implement watchdog mechanisms:
- Restart on crash (KeepAlive)
- Abort on repeated failures (ThrottleInterval)
- Log errors to persistent files

## Potential Pitfalls to Avoid

### 1. Not Handling User-Specific Paths

```swift
// BAD - Hardcoded user path
let agentPath = "/Users/john/Library/LaunchAgents/myagent.plist"

// GOOD - Use home directory
let agentPath = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Library/LaunchAgents/myagent.plist")
```

### 2. Missing Permissions

```bash
# BAD - Install without checking rights
cp MyAgent.plist ~/Library/LaunchAgents/

# GOOD - Verify directory exists and writable
mkdir -p ~/Library/LaunchAgents
cp MyAgent.plist ~/Library/LaunchAgents/
chmod 644 MyAgent.plist
```

### 3. Not Using ServiceManagement on macOS 13+

```swift
// BAD - Only using legacy launchctl
enableLegacy()

// GOOD - Use modern API when available
if #available(macOS 13.0, *) {
    SMAppService.register(...)
} else {
    enableLegacy()
}
```

### 4. Forget to Unload Before Update

```bash
# BAD - Overwrite while loaded
cp NewAgent.plist ~/Library/LaunchAgents/MyAgent.plist

# GOOD - Unload first
launchctl unload ~/Library/LaunchAgents/MyAgent.plist
cp NewAgent.plist ~/Library/LaunchAgents/MyAgent.plist
launchctl load -w ~/Library/LaunchAgents/MyAgent.plist
```

## Apple Documentation References

- [launchd](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)
- [launchd.plist Keys](https://manpages.org/launchd.plist)
- [ServiceManagement](https://developer.apple.com/documentation/servicemanagement)
- [SMAppService](https://developer.apple.com/documentation/servicemanagement/smappservice)

## Common launchd.plist Keys

| Key | Type | Description |
|-----|------|-------------|
| `Label` | String | Unique identifier (required) |
| `ProgramArguments` | Array | Executable and arguments |
| `RunAtLoad` | Boolean | Start immediately on load |
| `KeepAlive` | Boolean/Dict | Auto-restart on exit |
| `WorkingDirectory` | String | Working directory |
| `StandardOutPath` | String | Stdout log path |
| `StandardErrorPath` | String | Stderr log path |
| `LimitLoadToSessionType` | Array | Session types to load |
| `EnvironmentVariables` | Dict | Environment variables |
| `Nice` | Integer | Process priority |
| `ThrottleInterval` | Integer | Throttle interval (seconds) |

## Best Practices Summary

1. **Use SMAppService**: Prefer modern API on macOS 13+
2. **Proper Plist Format**: Ensure valid XML structure
3. **Unique Labels**: Use reverse-DNS bundle identifiers
4. **Logging**: Configure stdout/stderr paths for debugging
5. **Test Installation**: Verify install works for different users
6. **Permission Handling**: Use Authorization Services for admin tasks
7. **Cleanup on Uninstall**: Remove all files and launch config
8. **Version Compatibility**: Test on multiple macOS versions
9. **KeepAlive Wisely**: Don't auto-restart if failing repeatedly
10. **User-Specific Installation**: Install to user's home, not system

## Installation Directories

| Directory | Purpose | Write Access |
|-----------|---------|--------------|
| `~/Library/LaunchAgents/` | User agents | User |
| `/Library/LaunchAgents/` | All users agents | Admin |
| `/Library/LaunchDaemons/` | System daemons | Admin |
| `/Library/Application Support/` | Helper tools | Admin |
| `~/Library/Application Support/` | User tools | User |

<!-- nav -->

---

[< Previous: macOS App Bundle Structure for Utilities](08-app-bundle.md) | [Table of Contents](../../product-spec.md) | [Next: Common Clipboard Manager UX Patterns >](10-ux-patterns.md)

<!-- nav -->
