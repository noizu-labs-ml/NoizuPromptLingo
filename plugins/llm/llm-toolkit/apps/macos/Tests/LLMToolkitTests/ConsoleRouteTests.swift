import XCTest
@testable import LLMToolkitKit

final class ConsoleRouteTests: XCTestCase {
    func testCatalogCoversEveryWebAppRoute() {
        let paths = Set(ConsoleRoute.catalog.map(\.pathname))
        let expected: Set<String> = [
            "/",
            "/search",
            "/browse",
            "/safety-watch",
            "/thread/:id",
            "/thread/:id/continue",
            "/thread/:id/edit",
            "/thread/:id/convert",
            "/datasets",
            "/datasets/:name",
            "/prompts",
            "/tags",
            "/projects",
            "/projects/:slug",
            "/settings",
            "/style-guides",
            "/style-guides/:slug",
        ]
        XCTAssertEqual(paths, expected)
    }

    func testParseURLPreservesQuery() {
        let url = URL(string: "http://127.0.0.1:5173/search?q=auth&mode=semantic")!
        let route = ConsoleRoute.parse(url: url)
        XCTAssertEqual(route.pathname, "/search")
        XCTAssertEqual(route.query, "q=auth&mode=semantic")
        XCTAssertEqual(route.sidebarItem, .explore)
        XCTAssertEqual(route.title, "Search")
    }

    func testThreadFamilyRoutes() {
        let edit = ConsoleRoute.parse(pathFromHost: "/thread/abc123/edit")
        XCTAssertEqual(edit.threadID, "abc123")
        XCTAssertTrue(edit.isThreadFamily)
        XCTAssertEqual(edit.sidebarItem, .explore)
        XCTAssertEqual(edit.title, "Edit Thread")
        XCTAssertEqual(ConsoleRoute.threadConvert(id: "abc123").path, "/thread/abc123/convert")
        XCTAssertEqual(ConsoleRoute.threadContinue(id: "abc123").path, "/thread/abc123/continue")
    }

    func testExploreSearchQuery() {
        let route = ConsoleRoute.explore(query: "auth middleware")
        XCTAssertEqual(route.pathname, "/")
        XCTAssertNotNil(route.query)
        XCTAssertTrue(route.query?.contains("q=auth") == true)
        XCTAssertTrue(route.query?.contains("mode=fts") == true)
    }

    func testSidebarMapping() {
        XCTAssertEqual(ConsoleRoute.datasets.sidebarItem, .datasets)
        XCTAssertEqual(ConsoleRoute.dataset(name: "gold").sidebarItem, .datasets)
        XCTAssertEqual(ConsoleRoute.project(slug: "noizu").sidebarItem, .projects)
        XCTAssertEqual(ConsoleRoute.safetyWatch.sidebarItem, .safetyWatch)
        XCTAssertEqual(ConsoleRoute.settings.sidebarItem, .settings)
        XCTAssertEqual(ConsoleRoute.styleGuide.sidebarItem, .styleGuide)
    }

    func testURLRelativeToBase() {
        let url = ConsoleRoute.thread(id: "x").url(relativeTo: URL(string: "http://127.0.0.1:5173/")!)
        XCTAssertEqual(url?.absoluteString, "http://127.0.0.1:5173/thread/x")
    }

    func testNormalizeStripsTrailingSlash() {
        XCTAssertEqual(ConsoleRoute(path: "/projects/").path, "/projects")
        XCTAssertEqual(ConsoleRoute(path: "/").path, "/")
    }
}
