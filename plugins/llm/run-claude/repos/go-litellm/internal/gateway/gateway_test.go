package gateway

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/noizu-labs/go-litellm/internal/config"
	"github.com/noizu-labs/go-litellm/internal/runtime"
)

func testApp(t *testing.T, master string) *App {
	t.Helper()
	cfg := config.Empty()
	app := New(runtime.Settings{
		Host:        "127.0.0.1",
		Port:        0,
		MasterKey:   master,
		DatabaseURL: ":memory:",
	}, cfg)
	t.Cleanup(app.Close)
	return app
}

func TestHealthAndBanner(t *testing.T) {
	app := testApp(t, "")
	ts := httptest.NewServer(app.Handler())
	defer ts.Close()

	resp, err := http.Get(ts.URL + "/")
	if err != nil {
		t.Fatal(err)
	}
	b, _ := io.ReadAll(resp.Body)
	resp.Body.Close()
	if string(b) != "LiteLLM: RUNNING" {
		t.Fatalf("%q", b)
	}

	resp, _ = http.Get(ts.URL + "/health")
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		t.Fatal(resp.Status)
	}
	resp, _ = http.Get(ts.URL + "/health/readiness")
	defer resp.Body.Close()
	var body map[string]any
	_ = json.NewDecoder(resp.Body).Decode(&body)
	if body["status"] != "connected" || body["litellm_version"] == nil {
		t.Fatalf("%+v", body)
	}
}

func TestMasterKeyAuth(t *testing.T) {
	app := testApp(t, "sk-test")
	ts := httptest.NewServer(app.Handler())
	defer ts.Close()

	resp, _ := http.Get(ts.URL + "/v1/models")
	if resp.StatusCode != 401 {
		t.Fatalf("unauthed %d", resp.StatusCode)
	}
	resp.Body.Close()

	req, _ := http.NewRequest("GET", ts.URL+"/v1/models", nil)
	req.Header.Set("Authorization", "Bearer sk-test")
	resp, _ = http.DefaultClient.Do(req)
	if resp.StatusCode != 200 {
		t.Fatalf("authed %d", resp.StatusCode)
	}
	resp.Body.Close()
}

func TestModelCRUD(t *testing.T) {
	app := testApp(t, "sk")
	ts := httptest.NewServer(app.Handler())
	defer ts.Close()

	payload := `{"model_name":"groq-llama","litellm_params":{"model":"groq/llama","api_key":"secret"}}`
	req, _ := http.NewRequest("POST", ts.URL+"/model/new", strings.NewReader(payload))
	req.Header.Set("Authorization", "Bearer sk")
	req.Header.Set("Content-Type", "application/json")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	if resp.StatusCode != 200 {
		b, _ := io.ReadAll(resp.Body)
		t.Fatalf("%d %s", resp.StatusCode, b)
	}
	var created map[string]any
	_ = json.NewDecoder(resp.Body).Decode(&created)
	resp.Body.Close()
	if created["model_id"] == nil {
		t.Fatalf("%+v", created)
	}

	req, _ = http.NewRequest("GET", ts.URL+"/model/info", nil)
	req.Header.Set("Authorization", "Bearer sk")
	resp, _ = http.DefaultClient.Do(req)
	var info map[string]any
	_ = json.NewDecoder(resp.Body).Decode(&info)
	resp.Body.Close()
	data := info["data"].([]any)
	row := data[0].(map[string]any)
	lp := row["litellm_params"].(map[string]any)
	if lp["api_key"] != "****" {
		t.Fatalf("key not redacted: %v", lp["api_key"])
	}

	req, _ = http.NewRequest("GET", ts.URL+"/api/claude_cli/bootstrap", nil)
	resp, _ = http.DefaultClient.Do(req)
	var boot map[string]any
	_ = json.NewDecoder(resp.Body).Decode(&boot)
	resp.Body.Close()
	opts := boot["additional_model_options"].([]any)
	if len(opts) != 1 {
		t.Fatalf("%+v", boot)
	}
}

func TestChatCompletionsViaFakeUpstream(t *testing.T) {
	up := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/chat/completions" {
			t.Errorf("path %s", r.URL.Path)
		}
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"id":"chatcmpl-1","object":"chat.completion","choices":[{"index":0,"message":{"role":"assistant","content":"pong"},"finish_reason":"stop"}],"usage":{"prompt_tokens":1,"completion_tokens":1,"total_tokens":2}}`))
	}))
	defer up.Close()

	app := testApp(t, "sk")
	app.Router.Add(map[string]any{
		"model_name": "echo",
		"litellm_params": map[string]any{
			"model":    "openai/gpt-4o-mini",
			"api_base": up.URL,
			"api_key":  "k",
		},
	})
	ts := httptest.NewServer(app.Handler())
	defer ts.Close()

	body := `{"model":"echo","messages":[{"role":"user","content":"hi"}]}`
	req, _ := http.NewRequest("POST", ts.URL+"/v1/chat/completions", bytes.NewReader([]byte(body)))
	req.Header.Set("Authorization", "Bearer sk")
	req.Header.Set("Content-Type", "application/json")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != 200 {
		t.Fatalf("%d %s", resp.StatusCode, raw)
	}
	if !strings.Contains(string(raw), "pong") {
		t.Fatalf("%s", raw)
	}
}

func TestMessagesClaudePassthrough(t *testing.T) {
	var gotKey, gotPath string
	up := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotKey = r.Header.Get("X-Api-Key")
		gotPath = r.URL.Path
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"id":"msg_x","type":"message","role":"assistant","content":[{"type":"text","text":"ok"}]}`))
	}))
	defer up.Close()

	app := testApp(t, "sk")
	// Swap Anthropic host by using a custom passthrough isn't built-in for claude-*
	// (hardcoded api.anthropic.com). Instead register a non-claude anthropic-family
	// deployment pointing at the fake upstream.
	app.Router.Add(map[string]any{
		"model_name": "glm",
		"litellm_params": map[string]any{
			"model":    "anthropic/glm-5.2",
			"api_base": up.URL,
			"api_key":  "upstream-key",
		},
	})
	ts := httptest.NewServer(app.Handler())
	defer ts.Close()

	body := `{"model":"glm","messages":[{"role":"user","content":"hi"}],"max_tokens":8}`
	req, _ := http.NewRequest("POST", ts.URL+"/v1/messages", strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	raw, _ := io.ReadAll(resp.Body)
	resp.Body.Close()
	if resp.StatusCode != 200 {
		t.Fatalf("%d %s", resp.StatusCode, raw)
	}
	if gotKey != "upstream-key" {
		t.Fatalf("x-api-key=%q path=%s body=%s", gotKey, gotPath, raw)
	}
	if gotPath != "/v1/messages" {
		t.Fatalf("path=%s", gotPath)
	}
	if !strings.Contains(string(raw), "ok") {
		t.Fatalf("body %s", raw)
	}
}

func TestKeysSwitchChangesUpstreamAuth(t *testing.T) {
	var gotKey string
	up := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotKey = r.Header.Get("X-Api-Key")
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"id":"msg_x","type":"message","role":"assistant","content":[{"type":"text","text":"ok"}]}`))
	}))
	defer up.Close()

	app := testApp(t, "sk")
	app.Router.Keys.Put("zai", "default-secret", "ZAI_SUB_KEY", "env")
	app.Router.Keys.Put("tyna", "tyna-secret", "ZAI_SUB_KEY_TYNA", "env")
	app.Router.Add(map[string]any{
		"model_name": "zai/opus",
		"litellm_params": map[string]any{
			"model":        "anthropic/glm-5.3",
			"api_base":     up.URL,
			"api_key":      "default-secret",
			"api_key_name": "zai",
		},
	})
	app.Router.Add(map[string]any{
		"model_name": "zai-tyna/opus",
		"litellm_params": map[string]any{
			"model":        "anthropic/glm-5.3",
			"api_base":     up.URL,
			"api_key":      "tyna-secret",
			"api_key_name": "tyna",
		},
	})

	ts := httptest.NewServer(app.Handler())
	defer ts.Close()

	call := func(model string) {
		t.Helper()
		body := `{"model":"` + model + `","messages":[{"role":"user","content":"hi"}],"max_tokens":8}`
		req, _ := http.NewRequest("POST", ts.URL+"/v1/messages", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatal(err)
		}
		_, _ = io.ReadAll(resp.Body)
		resp.Body.Close()
		if resp.StatusCode != 200 {
			t.Fatalf("%s status %d", model, resp.StatusCode)
		}
	}

	call("zai/opus")
	if gotKey != "default-secret" {
		t.Fatalf("before switch key=%q", gotKey)
	}

	payload := `{"target":"zai","key":"tyna"}`
	req, _ := http.NewRequest("POST", ts.URL+"/keys/switch", strings.NewReader(payload))
	req.Header.Set("Authorization", "Bearer sk")
	req.Header.Set("Content-Type", "application/json")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	raw, _ := io.ReadAll(resp.Body)
	resp.Body.Close()
	if resp.StatusCode != 200 {
		t.Fatalf("switch %d %s", resp.StatusCode, raw)
	}
	if !strings.Contains(string(raw), "zai/opus") {
		t.Fatalf("switch body %s", raw)
	}
	if strings.Contains(string(raw), "zai-tyna/opus") {
		t.Fatalf("must not rebind tyna family: %s", raw)
	}

	call("zai/opus")
	if gotKey != "tyna-secret" {
		t.Fatalf("after switch key=%q", gotKey)
	}

	req, _ = http.NewRequest("GET", ts.URL+"/keys", nil)
	req.Header.Set("Authorization", "Bearer sk")
	resp, _ = http.DefaultClient.Do(req)
	var listing map[string]any
	_ = json.NewDecoder(resp.Body).Decode(&listing)
	resp.Body.Close()
	keys, _ := listing["keys"].([]any)
	if len(keys) < 2 {
		t.Fatalf("keys %+v", listing)
	}
}

func TestKeysPutAndDelete(t *testing.T) {
	app := testApp(t, "sk")
	ts := httptest.NewServer(app.Handler())
	defer ts.Close()

	payload := `{"name":"extra","api_key":"sk-extra"}`
	req, _ := http.NewRequest("POST", ts.URL+"/keys", strings.NewReader(payload))
	req.Header.Set("Authorization", "Bearer sk")
	req.Header.Set("Content-Type", "application/json")
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	if resp.StatusCode != 200 {
		b, _ := io.ReadAll(resp.Body)
		t.Fatalf("%d %s", resp.StatusCode, b)
	}
	resp.Body.Close()

	if app.Router.Keys.Value("extra") != "sk-extra" {
		t.Fatal("stored")
	}

	req, _ = http.NewRequest("POST", ts.URL+"/keys/delete", strings.NewReader(`{"name":"extra"}`))
	req.Header.Set("Authorization", "Bearer sk")
	req.Header.Set("Content-Type", "application/json")
	resp, _ = http.DefaultClient.Do(req)
	resp.Body.Close()
	if app.Router.Keys.Get("extra") != nil {
		t.Fatal("still present")
	}
}
