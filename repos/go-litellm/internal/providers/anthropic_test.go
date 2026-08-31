package providers

import "testing"

func TestAnthropicTransformRequestHoistsSystem(t *testing.T) {
	req := &Request{
		Model: "claude-haiku-4-5",
		Messages: []any{
			map[string]any{"role": "system", "content": "You are terse."},
			map[string]any{"role": "user", "content": "hi"},
		},
		Params: map[string]any{"max_tokens": 10},
	}
	body := Anthropic.TransformRequest(req)
	if body["system"] != "You are terse." {
		t.Fatalf("system=%v", body["system"])
	}
	msgs := body["messages"].([]any)
	if len(msgs) != 1 {
		t.Fatalf("messages %+v", msgs)
	}
	if body["max_tokens"] != 10 {
		t.Fatalf("max_tokens=%v", body["max_tokens"])
	}
}

func TestAnthropicDefaultMaxTokens(t *testing.T) {
	req := &Request{Model: "claude", Messages: []any{map[string]any{"role": "user", "content": "x"}}, Params: map[string]any{}}
	body := Anthropic.TransformRequest(req)
	if _, ok := body["max_tokens"].(int); !ok {
		t.Fatalf("max_tokens=%T %v", body["max_tokens"], body["max_tokens"])
	}
}

func TestAnthropicStopAndTools(t *testing.T) {
	req := &Request{
		Model:    "claude",
		Messages: []any{map[string]any{"role": "user", "content": "x"}},
		Params: map[string]any{
			"max_tokens": 5,
			"stop":       []any{"END"},
			"tools": []any{
				map[string]any{"function": map[string]any{"name": "get_weather", "description": "w", "parameters": map[string]any{"type": "object"}}},
			},
		},
	}
	body := Anthropic.TransformRequest(req)
	if _, ok := body["stop_sequences"]; !ok {
		t.Fatal("missing stop_sequences")
	}
	tools := body["tools"].([]any)
	tm := tools[0].(map[string]any)
	if tm["name"] != "get_weather" {
		t.Fatalf("%+v", tm)
	}
}

func TestAnthropicTransformResponse(t *testing.T) {
	raw := map[string]any{
		"id": "msg_1", "model": "claude-haiku-4-5", "stop_reason": "end_turn",
		"content": []any{map[string]any{"type": "text", "text": "PONG"}},
		"usage":   map[string]any{"input_tokens": 5, "output_tokens": 2},
	}
	resp := Anthropic.TransformResponse(raw, &Request{Model: "claude"})
	ch := resp.Choices[0].(map[string]any)
	msg := ch["message"].(map[string]any)
	if msg["content"] != "PONG" || ch["finish_reason"] != "stop" {
		t.Fatalf("%+v", ch)
	}
	u := resp.Usage.(map[string]any)
	if u["prompt_tokens"] != 5 || u["completion_tokens"] != 2 || u["total_tokens"] != 7 {
		t.Fatalf("%+v", u)
	}
}

func TestAnthropicToolUse(t *testing.T) {
	raw := map[string]any{
		"id": "msg_2", "stop_reason": "tool_use",
		"content": []any{
			map[string]any{"type": "tool_use", "id": "t1", "name": "get_weather", "input": map[string]any{"city": "SF"}},
		},
	}
	resp := Anthropic.TransformResponse(raw, &Request{Model: "claude"})
	ch := resp.Choices[0].(map[string]any)
	if ch["finish_reason"] != "tool_calls" {
		t.Fatalf("%v", ch["finish_reason"])
	}
	msg := ch["message"].(map[string]any)
	tcs := msg["tool_calls"].([]any)
	tc := tcs[0].(map[string]any)
	if tc["id"] != "t1" {
		t.Fatalf("%+v", tc)
	}
}

func TestAnthropicChunkParser(t *testing.T) {
	c := Anthropic.ChunkParser(map[string]any{
		"type": "content_block_delta", "index": 0,
		"delta": map[string]any{"type": "text_delta", "text": "hi"},
	})
	if c.Text != "hi" || c.IsFinished {
		t.Fatalf("%+v", c)
	}
	c = Anthropic.ChunkParser(map[string]any{
		"type":  "message_delta",
		"delta": map[string]any{"stop_reason": "end_turn"},
		"usage": map[string]any{"input_tokens": 1, "output_tokens": 3},
	})
	if !c.IsFinished || c.FinishReason != "stop" {
		t.Fatalf("%+v", c)
	}
	c = Anthropic.ChunkParser(map[string]any{"type": "message_stop"})
	if !c.Done {
		t.Fatal("expected done")
	}
}
