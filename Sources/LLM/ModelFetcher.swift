import Foundation

struct ModelListResponse: Decodable {
    struct Model: Decodable {
        var id: String?
        var name: String?
    }
    var data: [Model]?
    var models: [Model]?
}

struct OllamaListResponse: Decodable {
    struct Model: Decodable {
        var name: String
    }
    var models: [Model]
}

struct AnthropicListResponse: Decodable {
    struct Model: Decodable {
        var id: String
    }
    var data: [Model]
}

func fetchModels(provider: String, apiKey: String?, baseUrl: String?) async -> [String] {
    switch provider {
    case "anthropic":
        return await fetchAnthropicModels(apiKey: apiKey)
    case "openai":
        return await fetchOpenAICompatibleModels(
            url: "https://api.openai.com/v1/models",
            apiKey: apiKey,
            bearer: true
        )
    case "groq":
        return await fetchOpenAICompatibleModels(
            url: "https://api.groq.com/openai/v1/models",
            apiKey: apiKey,
            bearer: true
        )
    case "cerebras":
        return await fetchOpenAICompatibleModels(
            url: "https://api.cerebras.ai/v1/models",
            apiKey: apiKey,
            bearer: true
        )
    case "deepseek":
        return await fetchOpenAICompatibleModels(
            url: "https://api.deepseek.com/v1/models",
            apiKey: apiKey,
            bearer: true
        )
    case "zai":
        return await fetchOpenAICompatibleModels(
            url: "https://open.bigmodel.cn/api/paas/v4/models",
            apiKey: apiKey,
            bearer: true
        )
    case "litellm":
        let url = (baseUrl ?? "https://inference.noizu.com/v1") + "/models"
        return await fetchOpenAICompatibleModels(url: url, apiKey: apiKey, bearer: true)
    case "ollama":
        let url = (baseUrl ?? "http://localhost:11434") + "/api/tags"
        return await fetchOllamaModels(url: url)
    case "custom":
        if let base = baseUrl, !base.isEmpty {
            let url = base.hasSuffix("/") ? base + "models" : base + "/models"
            return await fetchOpenAICompatibleModels(url: url, apiKey: apiKey, bearer: true)
        }
        return []
    default:
        return []
    }
}

private func fetchAnthropicModels(apiKey: String?) async -> [String] {
    guard let key = apiKey, !key.isEmpty else { return [] }
    guard let url = URL(string: "https://api.anthropic.com/v1/models?limit=100") else { return [] }

    var request = URLRequest(url: url)
    request.setValue(key, forHTTPHeaderField: "x-api-key")
    request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

    guard let (data, _) = try? await URLSession.shared.data(for: request),
          let response = try? JSONDecoder().decode(AnthropicListResponse.self, from: data) else {
        return []
    }
    return response.data.map(\.id).sorted()
}

private func fetchOpenAICompatibleModels(url: String, apiKey: String?, bearer: Bool) async -> [String] {
    guard let url = URL(string: url) else { return [] }

    var request = URLRequest(url: url)
    if let key = apiKey, !key.isEmpty, bearer {
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
    }

    guard let (data, _) = try? await URLSession.shared.data(for: request),
          let response = try? JSONDecoder().decode(ModelListResponse.self, from: data) else {
        return []
    }

    let models = (response.data ?? response.models ?? [])
    return models.compactMap { $0.id ?? $0.name }.sorted()
}

private func fetchOllamaModels(url: String) async -> [String] {
    guard let url = URL(string: url) else { return [] }

    var request = URLRequest(url: url)
    request.timeoutInterval = 5

    guard let (data, _) = try? await URLSession.shared.data(for: request),
          let response = try? JSONDecoder().decode(OllamaListResponse.self, from: data) else {
        return []
    }
    return response.models.map(\.name).sorted()
}
