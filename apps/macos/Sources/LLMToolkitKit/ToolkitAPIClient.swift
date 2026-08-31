import Foundation

public struct CloneResult: Equatable, Sendable {
    public var id: String
    public init(id: String) { self.id = id }
}

public protocol ToolkitAPI: Sendable {
    func cloneConversation(id: String) async throws -> CloneResult
    func archiveConversation(id: String) async throws
    func rebuildIndex() async throws
}

public struct ToolkitAPIClient: ToolkitAPI, Sendable {
    public var apiURL: URL
    private let session: URLSession

    public init(apiURL: URL, session: URLSession = .shared) {
        self.apiURL = apiURL
        self.session = session
    }

    public func cloneConversation(id: String) async throws -> CloneResult {
        let url = endpoint("api/conversations/\(id)/clone")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await session.data(for: request)
        try Self.throwIfNeeded(response: response, data: data)
        let decoded = try JSONDecoder().decode(DataEnvelope<IDPayload>.self, from: data)
        return CloneResult(id: decoded.data.id)
    }

    public func archiveConversation(id: String) async throws {
        let url = endpoint("api/conversations/\(id)/archive")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let (data, response) = try await session.data(for: request)
        try Self.throwIfNeeded(response: response, data: data)
    }

    public func rebuildIndex() async throws {
        let url = endpoint("api/index/rebuild")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let (data, response) = try await session.data(for: request)
        try Self.throwIfNeeded(response: response, data: data)
    }

    private func endpoint(_ path: String) -> URL {
        var base = apiURL.absoluteString
        if base.hasSuffix("/") { base.removeLast() }
        let suffix = path.hasPrefix("/") ? path : "/" + path
        return URL(string: base + suffix) ?? apiURL.appendingPathComponent(path)
    }

    private static func throwIfNeeded(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(http.statusCode) else {
            if let body = try? JSONDecoder().decode(ErrorBody.self, from: data), let error = body.error {
                throw ToolkitAPIError.server(error)
            }
            throw ToolkitAPIError.http(http.statusCode)
        }
    }
}

public enum ToolkitAPIError: LocalizedError, Equatable {
    case http(Int)
    case server(String)

    public var errorDescription: String? {
        switch self {
        case .http(let code): return "API error \(code)"
        case .server(let message): return message
        }
    }
}

private struct DataEnvelope<T: Decodable>: Decodable {
    var data: T
}

private struct IDPayload: Decodable {
    var id: String
}

private struct ErrorBody: Decodable {
    var error: String?
}
