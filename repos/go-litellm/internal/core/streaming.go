package core

import (
	"bufio"
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/noizu-labs/go-litellm/internal/anthropic"
	"github.com/noizu-labs/go-litellm/internal/errx"
	"github.com/noizu-labs/go-litellm/internal/jsonx"
	"github.com/noizu-labs/go-litellm/internal/providers"
)

// StreamOpenAI streams a chat completion as OpenAI SSE (`data: …` + `[DONE]`).
func StreamOpenAI(w http.ResponseWriter, client HTTPDoer, p *Prepared) *errx.Error {
	return runStream(w, client, p, streamOpenAI{chunkID: "chatcmpl-" + providers.RandID(16), created: time.Now().Unix()})
}

// StreamAnthropic streams OpenAI-family upstream as Anthropic SSE events.
func StreamAnthropic(w http.ResponseWriter, client HTTPDoer, p *Prepared, requestedModel string) *errx.Error {
	return runStream(w, client, p, &streamAnthropic{model: requestedModel})
}

type emitter interface {
	preamble(http.ResponseWriter) error
	emit(http.ResponseWriter, providers.StreamChunk) error
	closing(http.ResponseWriter) error
}

type streamOpenAI struct {
	chunkID string
	created int64
	model   string
}

func (s streamOpenAI) preamble(http.ResponseWriter) error { return nil }

func (s streamOpenAI) emit(w http.ResponseWriter, chunk providers.StreamChunk) error {
	delta := map[string]any{}
	if chunk.Text != "" {
		delta["content"] = chunk.Text
	}
	if chunk.ToolUse != nil {
		delta["tool_calls"] = chunk.ToolUse
	}
	frame := map[string]any{
		"id":      s.chunkID,
		"object":  "chat.completion.chunk",
		"created": s.created,
		"model":   s.model,
		"choices": []any{
			map[string]any{
				"index":         chunk.Index,
				"delta":         delta,
				"finish_reason": chunk.FinishReason,
			},
		},
	}
	if chunk.Usage != nil {
		frame["usage"] = chunk.Usage
	}
	return writeSSEData(w, frame)
}

func (s streamOpenAI) closing(w http.ResponseWriter) error {
	_, err := io.WriteString(w, "data: [DONE]\n\n")
	flush(w)
	return err
}

type streamAnthropic struct {
	model        string
	finishReason any
	usage        any
}

func (s *streamAnthropic) preamble(w http.ResponseWriter) error {
	for _, f := range anthropic.StreamPreamble(s.model) {
		if _, err := io.WriteString(w, f); err != nil {
			return err
		}
	}
	flush(w)
	return nil
}

func (s *streamAnthropic) emit(w http.ResponseWriter, chunk providers.StreamChunk) error {
	if chunk.FinishReason != nil {
		s.finishReason = chunk.FinishReason
	}
	if chunk.Usage != nil {
		s.usage = chunk.Usage
	}
	text := chunk.Text
	if text == "" {
		text = chunk.Reasoning
	}
	if text == "" {
		return nil
	}
	_, err := io.WriteString(w, anthropic.StreamTextDelta(text))
	flush(w)
	return err
}

func (s *streamAnthropic) closing(w http.ResponseWriter) error {
	finish := ""
	if s.finishReason != nil {
		finish = stringifyAny(s.finishReason)
	}
	usage := jsonx.AsMap(s.usage)
	for _, f := range anthropic.StreamClosing(finish, usage) {
		if _, err := io.WriteString(w, f); err != nil {
			return err
		}
	}
	flush(w)
	return nil
}

func runStream(w http.ResponseWriter, client HTTPDoer, p *Prepared, em emitter) *errx.Error {
	if client == nil {
		client = DefaultClient
	}
	headers, e := p.Adapter.ValidateEnvironment(p.Req, map[string]string{})
	if e != nil {
		return e
	}
	if so, ok := em.(streamOpenAI); ok {
		so.model = p.Req.Model
		em = so
	}
	url := p.Adapter.CompleteURL(p.Req)
	payload := p.Adapter.TransformRequest(p.Req)
	raw, _ := json.Marshal(payload)
	httpReq, err := http.NewRequest(http.MethodPost, url, bytes.NewReader(raw))
	if err != nil {
		return errx.New(502, "upstream stream failed: "+err.Error())
	}
	for k, v := range headers {
		httpReq.Header.Set(k, v)
	}
	httpReq.Header.Del("Accept-Encoding")
	resp, err := client.Do(httpReq)
	if err != nil {
		return errx.New(502, "upstream stream failed: "+err.Error())
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		b, _ := io.ReadAll(resp.Body)
		return p.Adapter.ErrorClass(resp.StatusCode, decodeBody(b), nil)
	}

	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")
	w.WriteHeader(http.StatusOK)
	if err := em.preamble(w); err != nil {
		return nil
	}

	finished := false
	err = scanSSE(resp.Body, func(payload any, done bool) {
		if finished {
			return
		}
		if done {
			finished = true
			return
		}
		chunk := p.Adapter.ChunkParser(payload)
		if chunk.Done {
			finished = true
			return
		}
		_ = em.emit(w, chunk)
		if chunk.IsFinished {
			finished = true
		}
	})
	if err != nil {
		_ = writeSSEData(w, errx.New(502, "upstream stream failed: "+err.Error()).Body())
	}
	_ = em.closing(w)
	return nil
}

func scanSSE(r io.Reader, fn func(payload any, done bool)) error {
	br := bufio.NewReader(r)
	var event bytes.Buffer
	flushEvent := func() {
		data := extractData(event.String())
		event.Reset()
		if data == "" {
			return
		}
		if strings.TrimSpace(data) == "[DONE]" {
			fn(nil, true)
			return
		}
		var payload any
		if err := json.Unmarshal([]byte(data), &payload); err != nil {
			return
		}
		fn(payload, false)
	}
	for {
		line, err := br.ReadBytes('\n')
		if len(line) > 0 {
			if bytes.Equal(bytes.TrimSpace(line), []byte{}) {
				flushEvent()
			} else {
				event.Write(line)
			}
		}
		if err != nil {
			if event.Len() > 0 {
				flushEvent()
			}
			if err == io.EOF {
				return nil
			}
			return err
		}
	}
}

func extractData(event string) string {
	var parts []string
	for _, line := range strings.Split(event, "\n") {
		line = strings.TrimRight(line, "\r")
		if strings.HasPrefix(line, "data:") {
			parts = append(parts, strings.TrimSpace(strings.TrimPrefix(line, "data:")))
		}
	}
	return strings.Join(parts, "\n")
}

func writeSSEData(w http.ResponseWriter, v any) error {
	b, _ := json.Marshal(v)
	_, err := io.WriteString(w, "data: "+string(b)+"\n\n")
	flush(w)
	return err
}

func flush(w http.ResponseWriter) {
	if f, ok := w.(http.Flusher); ok {
		f.Flush()
	}
}

func stringifyAny(v any) string {
	if s, ok := v.(string); ok {
		return s
	}
	b, _ := json.Marshal(v)
	return strings.Trim(string(b), `"`)
}
