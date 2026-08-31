package core

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/noizu-labs/go-litellm/internal/errx"
	"github.com/noizu-labs/go-litellm/internal/jsonx"
	"github.com/noizu-labs/go-litellm/internal/providers"
)

// HTTPDoer is the outbound client surface (injectable in tests).
type HTTPDoer interface {
	Do(*http.Request) (*http.Response, error)
}

// DefaultClient never advertises compression (bodies are relayed verbatim).
var DefaultClient = &http.Client{
	Timeout: 10 * time.Minute,
	Transport: &http.Transport{
		Proxy:               http.ProxyFromEnvironment,
		MaxIdleConns:        200,
		IdleConnTimeout:     30 * time.Second,
		DisableCompression:  true,
		TLSHandshakeTimeout: 15 * time.Second,
	},
}

// DoCompletion runs validate → URL → transform → POST → transform_response.
func DoCompletion(client HTTPDoer, p *Prepared) (*providers.ModelResponse, *errx.Error) {
	body, e := DoRaw(client, p.Adapter, p.Req)
	if e != nil {
		return nil, e
	}
	return p.Adapter.TransformResponse(body, p.Req), nil
}

// DoRaw POSTs and returns the decoded upstream JSON body.
func DoRaw(client HTTPDoer, ad providers.Adapter, req *providers.Request) (map[string]any, *errx.Error) {
	if client == nil {
		client = DefaultClient
	}
	headers, e := ad.ValidateEnvironment(req, map[string]string{})
	if e != nil {
		return nil, e
	}
	url := ad.CompleteURL(req)
	payload := ad.TransformRequest(req)
	raw, _ := json.Marshal(payload)

	timeout := timeoutOf(req.LiteLLMParams, 10*time.Minute)
	var last *errx.Error
	for attempt := 0; attempt <= 2; attempt++ {
		httpReq, err := http.NewRequest(http.MethodPost, url, bytes.NewReader(raw))
		if err != nil {
			return nil, errx.New(502, "upstream request failed: "+err.Error())
		}
		for k, v := range headers {
			httpReq.Header.Set(k, v)
		}
		httpReq.Header.Del("Accept-Encoding")
		c := client
		if hc, ok := client.(*http.Client); ok && timeout > 0 {
			clone := *hc
			clone.Timeout = timeout
			c = &clone
		}
		resp, err := c.Do(httpReq)
		if err != nil {
			if attempt < 2 && retryable(err) {
				last = errx.New(502, "upstream request failed: "+err.Error())
				continue
			}
			return nil, errx.New(502, "upstream request failed: "+err.Error())
		}
		b, _ := io.ReadAll(resp.Body)
		_ = resp.Body.Close()
		decoded := decodeBody(b)
		if resp.StatusCode >= 200 && resp.StatusCode < 300 {
			return decoded, nil
		}
		return nil, ad.ErrorClass(resp.StatusCode, decoded, nil)
	}
	return nil, last
}

func decodeBody(b []byte) map[string]any {
	var m map[string]any
	if err := json.Unmarshal(b, &m); err != nil {
		return map[string]any{"error": map[string]any{"message": string(b)}}
	}
	return m
}

func timeoutOf(lp map[string]any, def time.Duration) time.Duration {
	if n, ok := jsonx.Float(lp, "timeout"); ok {
		return time.Duration(n * float64(time.Second))
	}
	return def
}

func retryable(err error) bool {
	if err == nil {
		return false
	}
	s := strings.ToLower(err.Error())
	for _, needle := range []string{
		"connection reset", "broken pipe", "eof", "use of closed network connection",
		"connection refused", "server closed idle connection",
	} {
		if strings.Contains(s, needle) {
			return true
		}
	}
	return false
}

// HeaderList converts a header map to a slice of pairs (for forwarding).
func HeaderMap(h http.Header) map[string]string {
	out := map[string]string{}
	for k, vs := range h {
		if len(vs) > 0 {
			out[k] = vs[0]
		}
	}
	return out
}
