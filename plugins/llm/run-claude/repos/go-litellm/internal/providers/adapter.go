package providers

import (
	"github.com/noizu-labs/go-litellm/internal/errx"
)

// Request is the per-call context passed to every adapter callback.
type Request struct {
	Model         string
	Provider      string
	Messages      []any
	Params        map[string]any
	LiteLLMParams map[string]any
	Stream        bool
	CallType      string // "chat" | "embedding" | "completion"
}

// StreamChunk is a normalized GenericStreamingChunk.
type StreamChunk struct {
	Text         string
	Reasoning    string
	IsFinished   bool
	FinishReason any
	Usage        any
	ToolUse      any
	Index        int
	Raw          any
	Done         bool
}

// ModelResponse is the OpenAI-shaped chat completion body.
type ModelResponse struct {
	ID                string `json:"id"`
	Object            string `json:"object"`
	Created           int64  `json:"created"`
	Model             string `json:"model"`
	Choices           []any  `json:"choices"`
	Usage             any    `json:"usage,omitempty"`
	SystemFingerprint any    `json:"system_fingerprint,omitempty"`
}

// Adapter is the provider behaviour (litellm BaseConfig).
type Adapter interface {
	Name() string
	SupportedParams(model string) []string
	MapOpenAIParams(nonDefault, optional map[string]any, model string, drop bool) map[string]any
	ValidateEnvironment(req *Request, headers map[string]string) (map[string]string, *errx.Error)
	CompleteURL(req *Request) string
	TransformRequest(req *Request) map[string]any
	TransformResponse(raw map[string]any, req *Request) *ModelResponse
	ErrorClass(status int, body any, headers map[string]string) *errx.Error
	ChunkParser(event any) StreamChunk
}
