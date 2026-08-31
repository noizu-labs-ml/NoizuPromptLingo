package version

// Version is reported by /health/readiness as litellm_version.
// Overridden at link time: -X github.com/noizu-labs/go-litellm/internal/version.Version=…
var Version = "0.1.0"
