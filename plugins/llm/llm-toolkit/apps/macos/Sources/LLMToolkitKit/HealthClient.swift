import Foundation

public struct ServiceHealth: Equatable, Sendable {
    public var apiOK: Bool
    public var indexStatus: String?
    public var conversationCount: Int?
    public var lastIndexed: String?
    public var detail: String?

    public init(
        apiOK: Bool = false,
        indexStatus: String? = nil,
        conversationCount: Int? = nil,
        lastIndexed: String? = nil,
        detail: String? = nil
    ) {
        self.apiOK = apiOK
        self.indexStatus = indexStatus
        self.conversationCount = conversationCount
        self.lastIndexed = lastIndexed
        self.detail = detail
    }

    public var isReady: Bool { apiOK }

    public var summary: String {
        if apiOK {
            if let indexStatus {
                return "Indexed · \(indexStatus)"
            }
            return "Ready"
        }
        return detail ?? "Starting…"
    }
}

public struct IndexStatus: Equatable, Sendable, Codable {
    public var status: String
    public var lastIndexed: String?
    public var conversationCount: Int

    public init(status: String, lastIndexed: String?, conversationCount: Int) {
        self.status = status
        self.lastIndexed = lastIndexed
        self.conversationCount = conversationCount
    }
}

public protocol HealthChecking: Sendable {
    func probe(apiURL: URL) async -> ServiceHealth
}

public struct HealthClient: HealthChecking, Sendable {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func probe(apiURL: URL) async -> ServiceHealth {
        let apiResult = await probeAPI(apiURL)
        return ServiceHealth(
            apiOK: apiResult.ok,
            indexStatus: apiResult.index?.status,
            conversationCount: apiResult.index?.conversationCount,
            lastIndexed: apiResult.index?.lastIndexed,
            detail: apiResult.detail
        )
    }

    private func probeAPI(_ base: URL) async -> (ok: Bool, index: IndexStatus?, detail: String?) {
        let healthURL = join(base, "api/health")
        do {
            let (data, response) = try await session.data(from: healthURL)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return (false, nil, "API health check failed")
            }
            if let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = body["status"] as? String,
               status != "ok" {
                return (false, nil, "API status \(status)")
            }
            let index = try? await fetchIndexStatus(base: base)
            return (true, index, nil)
        } catch {
            return (false, nil, error.localizedDescription)
        }
    }

    private func fetchIndexStatus(base: URL) async throws -> IndexStatus {
        let url = join(base, "api/index/status")
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoded = try JSONDecoder().decode(IndexStatusEnvelope.self, from: data)
        return decoded.data
    }
}

private struct IndexStatusEnvelope: Decodable {
    var data: IndexStatus
}

private func join(_ base: URL, _ path: String) -> URL {
    var value = base.absoluteString
    if value.hasSuffix("/") {
        value.removeLast()
    }
    let suffix = path.hasPrefix("/") ? path : "/" + path
    return URL(string: value + suffix) ?? base.appendingPathComponent(path)
}
