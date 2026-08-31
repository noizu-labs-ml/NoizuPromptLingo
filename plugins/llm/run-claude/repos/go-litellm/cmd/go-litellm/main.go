package main

import (
	"fmt"
	"log"
	"os"

	"github.com/noizu-labs/go-litellm/internal/config"
	"github.com/noizu-labs/go-litellm/internal/gateway"
	"github.com/noizu-labs/go-litellm/internal/runtime"
	"github.com/noizu-labs/go-litellm/internal/store"
	"github.com/noizu-labs/go-litellm/internal/version"
)

func main() {
	log.SetFlags(0)
	settings, msg, code := runtime.ParseArgs(os.Args[1:])
	if code == 0 {
		if msg == "version" {
			fmt.Println(version.Version)
			os.Exit(0)
		}
		fmt.Fprint(os.Stdout, msg)
		os.Exit(0)
	}
	if code > 0 {
		fmt.Fprint(os.Stderr, msg)
		if msg != "" && msg[len(msg)-1] != '\n' {
			fmt.Fprintln(os.Stderr)
		}
		os.Exit(code)
	}

	if settings.ConfigPath != "" {
		_ = os.Setenv("CONFIG_FILE_PATH", settings.ConfigPath)
	}

	cfg, err := config.LoadFile(settings.ConfigPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "go-litellm: failed to load config %s: %v\n", settings.ConfigPath, err)
		// Match ex-litellm: log and continue with empty config rather than hard-fail,
		// except a missing explicit --config file is a real error.
		os.Exit(1)
	}

	app := gateway.New(settings, cfg)
	defer app.Close()

	fmt.Fprint(os.Stderr, banner(settings, app))
	if err := app.ListenAndServe(); err != nil {
		fmt.Fprintf(os.Stderr, "go-litellm: startup failed: %v\n", err)
		os.Exit(1)
	}
}

func banner(s runtime.Settings, app *gateway.App) string {
	cfg := s.ConfigPath
	if cfg == "" {
		cfg = "(none — env/defaults)"
	}
	db := "sqlite (default path)"
	if s.DatabaseURL != "" {
		db = store.RedactURL(s.DatabaseURL)
	} else if app != nil && app.Store != nil && app.Store.Path() != "" {
		db = app.Store.Path()
	}
	return fmt.Sprintf(`[go-litellm] gateway: %s:%d
[go-litellm] config: %s
[go-litellm] db: %s
`, s.Host, s.Port, cfg, db)
}
