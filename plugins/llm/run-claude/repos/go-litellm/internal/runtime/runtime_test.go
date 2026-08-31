package runtime

import "testing"

func TestParseArgs(t *testing.T) {
	s, msg, code := ParseArgs([]string{"--host", "0.0.0.0", "--port", "4443", "--config", "/tmp/c.yaml"})
	if code != -1 || msg != "" {
		t.Fatalf("code=%d msg=%q", code, msg)
	}
	if s.Host != "0.0.0.0" || s.Port != 4443 || s.ConfigPath != "/tmp/c.yaml" {
		t.Fatalf("%+v", s)
	}
	_, _, code = ParseArgs([]string{"--help"})
	if code != 0 {
		t.Fatal("help")
	}
	_, _, code = ParseArgs([]string{"--nope"})
	if code != 2 {
		t.Fatal("invalid")
	}
}
