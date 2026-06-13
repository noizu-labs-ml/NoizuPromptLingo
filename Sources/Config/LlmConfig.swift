import Foundation

struct LlmConfig: Codable, Sendable {
    var provider: String = "anthropic"
    var model: String?
    var apiKey: String?
    var baseUrl: String?
    var apiType: String?

    static let providers = ["anthropic", "openai", "groq", "cerebras", "deepseek", "zai", "litellm", "ollama", "custom"]

    static let defaultModels: [String: String] = [
        "anthropic": "claude-sonnet-4-20250514",
        "openai": "gpt-4o",
        "groq": "llama-3.3-70b",
        "cerebras": "llama-3.3-70b",
        "deepseek": "deepseek-chat",
        "zai": "glm-4",
        "litellm": "claude-sonnet-4-6",
        "ollama": "llama3",
        "custom": "model-name",
    ]

    static let envVarKeys: [String: String] = [
        "anthropic": "ANTHROPIC_API_KEY",
        "openai": "OPENAI_API_KEY",
        "groq": "GROQ_API_KEY",
        "cerebras": "CEREBRAS_API_KEY",
        "deepseek": "DEEPSEEK_API_KEY",
        "zai": "ZAI_API_KEY",
        "litellm": "LITELLM_API_KEY",
    ]

    static let defaultBaseUrls: [String: String] = [
        "ollama": "http://localhost:11434",
        "litellm": "https://inference.noizu.com/v1",
    ]

    static let needsApiKey: Set<String> = ["anthropic", "openai", "groq", "cerebras", "deepseek", "zai", "litellm", "custom"]
    static let needsBaseUrl: Set<String> = ["ollama", "litellm", "custom"]

    var effectiveModel: String {
        model ?? LlmConfig.defaultModels[provider] ?? "claude-sonnet-4-20250514"
    }

    var effectiveApiKey: String? {
        if let key = apiKey, !key.isEmpty { return key }
        if let envVar = LlmConfig.envVarKeys[provider] {
            if let val = ProcessInfo.processInfo.environment[envVar], !val.isEmpty { return val }
        }
        if provider == "litellm" {
            return ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
        }
        return nil
    }

    var effectiveBaseUrl: String? {
        if let url = baseUrl, !url.isEmpty { return url }
        return LlmConfig.defaultBaseUrls[provider]
    }
}
