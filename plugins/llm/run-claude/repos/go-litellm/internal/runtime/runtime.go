// Package runtime holds the resolved launch settings (CLI > env > defaults).
package runtime

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

// Settings is the launch contract of the Python/Elixir litellm binary.
type Settings struct {
	Host           string
	Port           int
	ConfigPath     string
	MasterKey      string
	DatabaseURL    string
	StoreModelInDB bool
}

// Defaults match ex-litellm's compiled (dev) defaults: 127.0.0.1:4445.
func Defaults() Settings {
	return Settings{
		Host:           "127.0.0.1",
		Port:           4445,
		StoreModelInDB: true,
	}
}

// FromEnv builds settings from environment variables (litellm convention).
func FromEnv() Settings {
	s := Defaults()
	if v := env("EX_LITELLM_HOST"); v != "" {
		s.Host = v
	}
	if v := firstEnv("GO_LITELLM_HOST", "EX_LITELLM_HOST"); v != "" {
		s.Host = v
	}
	if v := firstEnv("GO_LITELLM_PORT", "EX_LITELLM_PORT", "PORT"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 {
			s.Port = n
		}
	}
	s.ConfigPath = firstEnv("CONFIG_FILE_PATH")
	s.MasterKey = firstEnv("LITELLM_MASTER_KEY")
	s.DatabaseURL = firstEnv("LITELLM_DATABASE_URL")
	if v := env("STORE_MODEL_IN_DB"); v != "" {
		s.StoreModelInDB = truthy(v, true)
	}
	return s
}

// Resolve overlays parsed CLI flags on env + defaults.
func Resolve(host string, port int, config string) Settings {
	s := FromEnv()
	if host != "" {
		s.Host = host
	}
	if port > 0 {
		s.Port = port
	}
	if config != "" {
		s.ConfigPath = config
	}
	return s
}

// ParseArgs understands the litellm-style CLI:
//
//	go-litellm [--host HOST] [--port PORT] [--config FILE]
func ParseArgs(argv []string) (Settings, string, int) {
	var host, config string
	port := 0
	for i := 0; i < len(argv); i++ {
		a := argv[i]
		switch {
		case a == "-h" || a == "--help":
			return Settings{}, usage(), 0
		case a == "--version" || a == "-V":
			return Settings{}, "version", 0
		case a == "--host" && i+1 < len(argv):
			i++
			host = argv[i]
		case strings.HasPrefix(a, "--host="):
			host = strings.TrimPrefix(a, "--host=")
		case (a == "--port" || a == "-p") && i+1 < len(argv):
			i++
			n, err := strconv.Atoi(argv[i])
			if err != nil {
				return Settings{}, fmt.Sprintf("go-litellm: invalid --port %q", argv[i]), 2
			}
			port = n
		case strings.HasPrefix(a, "--port="):
			n, err := strconv.Atoi(strings.TrimPrefix(a, "--port="))
			if err != nil {
				return Settings{}, fmt.Sprintf("go-litellm: invalid --port %q", a), 2
			}
			port = n
		case (a == "--config" || a == "-c") && i+1 < len(argv):
			i++
			config = argv[i]
		case strings.HasPrefix(a, "--config="):
			config = strings.TrimPrefix(a, "--config=")
		default:
			return Settings{}, fmt.Sprintf("go-litellm: invalid options: %s\n%s", a, usage()), 2
		}
	}
	return Resolve(host, port, config), "", -1
}

func usage() string {
	return `go-litellm — Go LiteLLM proxy (drop-in for the litellm / ex-litellm binary)

USAGE:
  go-litellm [--host HOST] [--port PORT] [--config FILE]

OPTIONS:
  -h, --help           Show this help
  --version            Print version
  --host HOST          Bind address (default 127.0.0.1)
  -p, --port PORT      Unified gateway port (default 4445 dev / 4443 via run-claude)
  -c, --config FILE    Path to litellm-style config.yaml

ENV:
  LITELLM_MASTER_KEY     Master key for admin/auth
  LITELLM_DATABASE_URL   postgres://… or sqlite path (default: local SQLite)
  STORE_MODEL_IN_DB      true|false (default true)
  CONFIG_FILE_PATH       Fallback config path when --config is omitted
`
}

func env(name string) string {
	v := strings.TrimSpace(os.Getenv(name))
	return v
}

func firstEnv(names ...string) string {
	for _, n := range names {
		if v := env(n); v != "" {
			return v
		}
	}
	return ""
}

func truthy(v string, defaultVal bool) bool {
	if v == "" {
		return defaultVal
	}
	switch strings.ToLower(v) {
	case "true", "1", "yes", "on":
		return true
	case "false", "0", "no", "off":
		return false
	default:
		return defaultVal
	}
}
