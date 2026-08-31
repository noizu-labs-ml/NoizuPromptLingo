// Package errx is the OpenAI-compatible error envelope LiteLLM clients expect.
package errx

import "net/http"

// Error is the OpenAI {"error":{message,type,code,param}} body plus HTTP status.
type Error struct {
	Message  string `json:"message"`
	Type     string `json:"type"`
	Code     any    `json:"code"`
	Param    any    `json:"param"`
	Status   int    `json:"-"`
	Provider string `json:"-"`
}

func (e *Error) Error() string {
	if e == nil {
		return "unknown error"
	}
	return e.Message
}

// New builds an error. typ is inferred from status when empty.
func New(status int, message string, opts ...Option) *Error {
	e := &Error{
		Status:  status,
		Message: message,
		Code:    status,
	}
	for _, opt := range opts {
		opt(e)
	}
	if e.Type == "" {
		e.Type = typeForStatus(status)
	}
	return e
}

// Option mutates an Error at construction.
type Option func(*Error)

func WithType(t string) Option     { return func(e *Error) { e.Type = t } }
func WithCode(c any) Option        { return func(e *Error) { e.Code = c } }
func WithParam(p any) Option       { return func(e *Error) { e.Param = p } }
func WithProvider(p string) Option { return func(e *Error) { e.Provider = p } }

// Body is the JSON envelope an OpenAI client expects.
func (e *Error) Body() map[string]any {
	if e == nil {
		return map[string]any{"error": map[string]any{"message": "unknown error", "type": "api_error"}}
	}
	return map[string]any{
		"error": map[string]any{
			"message": e.Message,
			"type":    e.Type,
			"code":    e.Code,
			"param":   e.Param,
		},
	}
}

// AnthropicBody is the Messages API error envelope.
func (e *Error) AnthropicBody() map[string]any {
	if e == nil {
		return map[string]any{"type": "error", "error": map[string]any{"type": "api_error", "message": "unknown error"}}
	}
	return map[string]any{
		"type": "error",
		"error": map[string]any{
			"type":    e.Type,
			"message": e.Message,
		},
	}
}

func typeForStatus(status int) string {
	switch status {
	case http.StatusBadRequest, http.StatusUnprocessableEntity:
		return "invalid_request_error"
	case http.StatusUnauthorized:
		return "authentication_error"
	case http.StatusForbidden:
		return "permission_error"
	case http.StatusNotFound:
		return "not_found_error"
	case http.StatusTooManyRequests:
		return "rate_limit_error"
	default:
		return "api_error"
	}
}
