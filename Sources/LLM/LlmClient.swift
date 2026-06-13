import Foundation

enum LlmError: Error, CustomStringConvertible {
    case noApiKey
    case requestFailed(Int, String)
    case timeout
    case decodingFailed(String)
    case invalidEntries([String])
    case emptyResponse

    var description: String {
        switch self {
        case .noApiKey: "No API key configured"
        case .requestFailed(let code, let msg): "HTTP \(code): \(msg)"
        case .timeout: "Request timed out (30s)"
        case .decodingFailed(let msg): "Failed to parse LLM response: \(msg)"
        case .invalidEntries(let paths): "Invalid queue paths: \(paths.joined(separator: ", "))"
        case .emptyResponse: "LLM returned empty response"
        }
    }
}

actor LlmClient {
    private let config: LlmConfig
    private let maxRetries = 3
    private let timeoutSeconds: TimeInterval = 30

    init(config: LlmConfig) {
        self.config = config
    }

    func classify(system: String, user: String) async throws -> ClassificationResponse {
        try await classifyWithTrace(system: system, user: user).response
    }

    func classifyWithTrace(system: String, user: String) async throws -> ClassificationResult {
        let responseText = try await sendWithRetry(system: system, user: user)
        let response = try parseAndValidate(responseText)
        return ClassificationResult(response: response, rawText: responseText)
    }

    private func sendWithRetry(system: String, user: String) async throws -> String {
        var lastError: Error = LlmError.emptyResponse
        for attempt in 0..<maxRetries {
            if attempt > 0 {
                let delay = Double(1 << attempt) + Double.random(in: 0...0.5)
                try await Task.sleep(for: .seconds(delay))
            }
            do {
                return try await send(system: system, user: user)
            } catch let error as LlmError {
                lastError = error
                if case .requestFailed(let code, _) = error {
                    if code == 429 || (code >= 500 && code < 600) {
                        continue
                    }
                }
                throw error
            } catch {
                lastError = error
                if (error as NSError).code == NSURLErrorTimedOut {
                    continue
                }
                throw error
            }
        }
        throw lastError
    }

    private func send(system: String, user: String) async throws -> String {
        if config.provider == "anthropic" {
            guard let apiKey = config.effectiveApiKey else {
                throw LlmError.noApiKey
            }
            return try await sendAnthropic(system: system, user: user, apiKey: apiKey)
        }

        return try await sendOpenAICompatible(
            system: system,
            user: user,
            apiKey: config.effectiveApiKey
        )
    }

    private func sendAnthropic(system: String, user: String, apiKey: String) async throws -> String {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeoutSeconds
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let body: [String: Any] = [
            "model": config.effectiveModel,
            "max_tokens": 4096,
            "system": system,
            "messages": [
                ["role": "user", "content": user]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as! HTTPURLResponse

        guard (200..<300).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            throw LlmError.requestFailed(httpResponse.statusCode, body)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let first = content.first,
              let text = first["text"] as? String else {
            throw LlmError.emptyResponse
        }
        return text
    }

    private func sendOpenAICompatible(system: String, user: String, apiKey: String?) async throws -> String {
        let baseUrl = config.effectiveBaseUrl ?? "https://api.openai.com/v1"
        let endpoint = baseUrl.hasSuffix("/") ? baseUrl + "chat/completions" : baseUrl + "/chat/completions"
        let url = URL(string: endpoint)!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeoutSeconds
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        if let key = apiKey {
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        }

        var body: [String: Any] = [
            "model": config.effectiveModel,
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": user],
            ]
        ]
        if !["ollama", "custom"].contains(config.provider) {
            body["response_format"] = ["type": "json_object"]
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as! HTTPURLResponse

        guard (200..<300).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            throw LlmError.requestFailed(httpResponse.statusCode, body)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let text = message["content"] as? String else {
            throw LlmError.emptyResponse
        }
        return text
    }

    private func parseAndValidate(_ text: String) throws -> ClassificationResponse {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        }
        if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            throw LlmError.decodingFailed("not valid UTF-8")
        }

        let response: ClassificationResponse
        do {
            response = try JSONDecoder().decode(ClassificationResponse.self, from: data)
        } catch {
            let preview = String(cleaned.prefix(200))
            throw LlmError.decodingFailed("\(error.localizedDescription) — response: \(preview)")
        }

        let validPaths = QueueManifest.validPaths()
        let invalidPaths = response.entries
            .map(\.file)
            .filter { !validPaths.contains($0) }

        if !invalidPaths.isEmpty {
            throw LlmError.invalidEntries(Array(Set(invalidPaths)))
        }

        return response
    }
}
