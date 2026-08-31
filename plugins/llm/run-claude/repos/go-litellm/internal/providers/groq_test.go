package providers

import "testing"

func TestShapeGroqGPTOss(t *testing.T) {
	out := ShapeGroq(map[string]any{"max_tokens": 64, "reasoning_effort": "max"}, "openai/gpt-oss-20b")
	if out["include_reasoning"] != false {
		t.Fatalf("include_reasoning: %v", out["include_reasoning"])
	}
	if out["max_completion_tokens"] != 2048 {
		t.Fatalf("max_completion_tokens: %v", out["max_completion_tokens"])
	}
	if _, ok := out["max_tokens"]; ok {
		t.Fatal("max_tokens should be aliased away")
	}
	if out["reasoning_effort"] != "high" {
		t.Fatalf("effort: %v", out["reasoning_effort"])
	}
	out = ShapeGroq(map[string]any{"reasoning_effort": "auto"}, "openai/gpt-oss-20b")
	if out["reasoning_effort"] != "medium" {
		t.Fatalf("auto: %v", out["reasoning_effort"])
	}
}

func TestShapeGroqDropsUnknownEffort(t *testing.T) {
	out := ShapeGroq(map[string]any{"reasoning_effort": "nope"}, "openai/gpt-oss-20b")
	if _, ok := out["reasoning_effort"]; ok {
		t.Fatalf("expected drop, got %v", out["reasoning_effort"])
	}
}

func TestShapeGroqStripsInvalidToolPatterns(t *testing.T) {
	body := map[string]any{
		"tools": []any{
			map[string]any{
				"type": "function",
				"function": map[string]any{
					"name": "Artifact",
					"parameters": map[string]any{
						"type": "object",
						"properties": map[string]any{
							"after": map[string]any{
								"type":    "string",
								"pattern": "^[A-Za-z0-9_=-]{1,4096}$",
							},
						},
					},
				},
			},
		},
	}
	out := ShapeGroq(body, "openai/gpt-oss-120b")
	tools := out["tools"].([]any)
	fn := tools[0].(map[string]any)["function"].(map[string]any)
	params := fn["parameters"].(map[string]any)
	props := params["properties"].(map[string]any)
	after := props["after"].(map[string]any)
	if _, ok := after["pattern"]; ok {
		t.Fatalf("pattern should be stripped: %+v", after)
	}
	if after["type"] != "string" {
		t.Fatalf("kept type: %+v", after)
	}
}

func TestShapeGroqLeavesNonGptOss(t *testing.T) {
	out := ShapeGroq(map[string]any{"max_tokens": 64}, "llama-3.1-8b-instant")
	if out["max_tokens"] != 64 {
		t.Fatalf("%v", out)
	}
	if _, ok := out["include_reasoning"]; ok {
		t.Fatal(out)
	}
}
