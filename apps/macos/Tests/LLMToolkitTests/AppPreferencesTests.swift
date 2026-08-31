import XCTest
@testable import LLMToolkitKit

final class AppPreferencesTests: XCTestCase {
    func testInMemoryRoundTrip() {
        let store = InMemoryPreferenceStore()
        var prefs = store.load()
        XCTAssertEqual(prefs.apiURL, AppPreferences.defaultAPIURL)
        XCTAssertEqual(prefs.apiURL.host, "localhost")
        XCTAssertTrue(prefs.autoStartServers)
        XCTAssertTrue(prefs.useNativeChrome)

        prefs.toolkitRootPath = "~/Work/llm-toolkit"
        prefs.autoStartServers = false
        store.save(prefs)
        XCTAssertEqual(store.load().toolkitRootPath, "~/Work/llm-toolkit")
        XCTAssertFalse(store.load().autoStartServers)
        XCTAssertEqual(store.load().toolkitRootURL?.path.hasSuffix("llm-toolkit"), true)
    }

    func testLaunchPlanQuotesRootAndUsesLoginShell() throws {
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("llm-toolkit-supervisor-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: temp.appendingPathComponent("packages/web"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: temp.appendingPathComponent("packages/api"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: temp.appendingPathComponent("bin"), withIntermediateDirectories: true)
        try Data("{}".utf8).write(to: temp.appendingPathComponent("packages/web/package.json"))
        try Data("{}".utf8).write(to: temp.appendingPathComponent("packages/api/package.json"))
        try Data("#!/bin/bash\n".utf8).write(to: temp.appendingPathComponent("bin/llm-toolkit"))
        defer { try? FileManager.default.removeItem(at: temp) }

        let supervisor = ServerSupervisor(
            locator: ToolkitLocator(
                environment: [:],
                homeDirectory: temp,
                currentDirectory: temp,
                considerCompilationPath: false
            ),
            pathEnvironment: ["PATH": "/usr/bin"]
        )
        var prefs = AppPreferences()
        prefs.toolkitRootPath = temp.path
        let plan = try supervisor.makeLaunchPlan(preferences: prefs)
        XCTAssertEqual(plan.executable.path, "/bin/zsh")
        XCTAssertEqual(plan.arguments.first, "-lc")
        XCTAssertTrue(plan.arguments[1].contains("pnpm dev:api"))
        XCTAssertTrue(plan.arguments[1].contains(supervisor.shellQuote(temp.path)))
        XCTAssertEqual(plan.currentDirectory.path, temp.path)
    }
}
