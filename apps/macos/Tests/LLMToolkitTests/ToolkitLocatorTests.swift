import XCTest
@testable import LLMToolkitKit

final class ToolkitLocatorTests: XCTestCase {
    func testFindsRootFromWalkAndEnv() throws {
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("llm-toolkit-locator-\(UUID().uuidString)", isDirectory: true)
        let root = temp.appendingPathComponent("checkout", isDirectory: true)
        try FileManager.default.createDirectory(at: root.appendingPathComponent("packages/web"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: root.appendingPathComponent("packages/api"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: root.appendingPathComponent("bin"), withIntermediateDirectories: true)
        try "web".write(to: root.appendingPathComponent("packages/web/package.json"), atomically: true, encoding: .utf8)
        try "api".write(to: root.appendingPathComponent("packages/api/package.json"), atomically: true, encoding: .utf8)
        try "#!/bin/bash\n".write(to: root.appendingPathComponent("bin/llm-toolkit"), atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: temp) }

        let nested = root.appendingPathComponent("apps/macos")
        try FileManager.default.createDirectory(at: nested, withIntermediateDirectories: true)

        let locator = ToolkitLocator(
            environment: [:],
            homeDirectory: temp,
            currentDirectory: nested,
            considerCompilationPath: false
        )
        XCTAssertEqual(locator.locate()?.path, root.path)

        let viaEnv = ToolkitLocator(
            environment: ["LLM_TOOLKIT_ROOT": root.path],
            homeDirectory: temp,
            currentDirectory: temp,
            considerCompilationPath: false
        )
        XCTAssertEqual(viaEnv.locate()?.path, root.path)
    }

    func testRejectsIncompleteTrees() throws {
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("llm-toolkit-locator-bad-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temp) }
        let locator = ToolkitLocator(
            environment: [:],
            homeDirectory: temp,
            currentDirectory: temp,
            considerCompilationPath: false
        )
        XCTAssertNil(locator.locate())
    }
}
