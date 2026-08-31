// Package store persists request logs (SQLite by default, no CGO).
package store

import (
	"database/sql"
	"log"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	_ "modernc.org/sqlite"
)

// Record is one gateway request.
type Record struct {
	ID         int64     `json:"id"`
	At         time.Time `json:"at"`
	Method     string    `json:"method"`
	Path       string    `json:"path"`
	Model      string    `json:"model,omitempty"`
	Target     string    `json:"target,omitempty"`
	Status     int       `json:"status"`
	DurationMS int64     `json:"duration_ms"`
	ReqBytes   int64     `json:"req_bytes"`
	RespBytes  int64     `json:"resp_bytes"`
	Stream     bool      `json:"stream"`
	Error      string    `json:"error,omitempty"`
}

// Stats aggregates a time window.
type Stats struct {
	WindowMinutes int   `json:"window_minutes"`
	Count         int   `json:"count"`
	Errors        int   `json:"errors"`
	AvgMS         int64 `json:"avg_ms"`
	MaxMS         int64 `json:"max_ms"`
	ReqBytes      int64 `json:"req_bytes"`
	RespBytes     int64 `json:"resp_bytes"`
}

// Store is a fire-and-forget SQLite request log.
type Store struct {
	db     *sql.DB
	ch     chan Record
	path   string
	closed chan struct{}
	once   sync.Once
}

const maxRows = 20_000

// Open opens (or creates) the SQLite file. databaseURL:
//
//	unset            → ~/.local/state/go-litellm/go_litellm.db
//	sqlite://path    → that path
//	bare path        → that path
//	postgres://…     → ignored; sqlite default (postgres lands later)
func Open(databaseURL string) (*Store, error) {
	path, err := resolvePath(databaseURL)
	if err != nil {
		return nil, err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return nil, err
	}
	db, err := sql.Open("sqlite", withPragmas(path))
	if err != nil {
		return nil, err
	}
	if err := migrate(db); err != nil {
		_ = db.Close()
		return nil, err
	}
	s := &Store{
		db:     db,
		ch:     make(chan Record, 256),
		path:   path,
		closed: make(chan struct{}),
	}
	go s.writer()
	return s, nil
}

// Path returns the sqlite file path.
func (s *Store) Path() string {
	if s == nil {
		return ""
	}
	return s.path
}

// Connected reports whether the DB is open.
func (s *Store) Connected() bool {
	return s != nil && s.db != nil
}

// Record queues a log row (never blocks the request path for long).
func (s *Store) Record(r Record) {
	if s == nil {
		return
	}
	if r.At.IsZero() {
		r.At = time.Now().UTC()
	}
	if len(r.Error) > 500 {
		r.Error = r.Error[:500]
	}
	select {
	case s.ch <- r:
	default:
		// drop rather than stall inference
	}
}

// Recent returns newest-first rows.
func (s *Store) Recent(limit int, errorsOnly bool, pathFilter string) []Record {
	if s == nil || s.db == nil {
		return nil
	}
	if limit <= 0 {
		limit = 100
	}
	if limit > 500 {
		limit = 500
	}
	q := `SELECT id, inserted_at, method, path, model, target, status, duration_ms, req_bytes, resp_bytes, stream, error
	      FROM request_logs`
	var args []any
	var where []string
	if errorsOnly {
		where = append(where, "(status >= 400 OR error IS NOT NULL AND error != '')")
	}
	if pathFilter != "" {
		where = append(where, "path LIKE ?")
		args = append(args, "%"+pathFilter+"%")
	}
	if len(where) > 0 {
		q += " WHERE " + strings.Join(where, " AND ")
	}
	q += " ORDER BY id DESC LIMIT ?"
	args = append(args, limit)

	rows, err := s.db.Query(q, args...)
	if err != nil {
		return nil
	}
	defer rows.Close()
	var out []Record
	for rows.Next() {
		var r Record
		var at string
		var stream int
		var model, target, errStr sql.NullString
		if err := rows.Scan(&r.ID, &at, &r.Method, &r.Path, &model, &target, &r.Status, &r.DurationMS, &r.ReqBytes, &r.RespBytes, &stream, &errStr); err != nil {
			continue
		}
		r.At, _ = time.Parse(time.RFC3339Nano, at)
		r.Model = model.String
		r.Target = target.String
		r.Stream = stream != 0
		r.Error = errStr.String
		out = append(out, r)
	}
	return out
}

// Stats aggregates the last `minutes`.
func (s *Store) Stats(minutes int) Stats {
	st := Stats{WindowMinutes: minutes}
	if s == nil || s.db == nil {
		return st
	}
	since := time.Now().UTC().Add(-time.Duration(minutes) * time.Minute).Format(time.RFC3339Nano)
	row := s.db.QueryRow(`SELECT
		COUNT(id),
		SUM(CASE WHEN status >= 400 OR (error IS NOT NULL AND error != '') THEN 1 ELSE 0 END),
		AVG(duration_ms),
		MAX(duration_ms),
		SUM(req_bytes),
		SUM(resp_bytes)
	FROM request_logs WHERE inserted_at >= ?`, since)
	var count, errors sql.NullInt64
	var avg, max, reqB, respB sql.NullFloat64
	if err := row.Scan(&count, &errors, &avg, &max, &reqB, &respB); err != nil {
		return st
	}
	st.Count = int(count.Int64)
	st.Errors = int(errors.Int64)
	st.AvgMS = int64(avg.Float64)
	st.MaxMS = int64(max.Float64)
	st.ReqBytes = int64(reqB.Float64)
	st.RespBytes = int64(respB.Float64)
	return st
}

// Close stops the writer.
func (s *Store) Close() {
	if s == nil {
		return
	}
	s.once.Do(func() {
		close(s.ch)
		<-s.closed
		_ = s.db.Close()
	})
}

func (s *Store) writer() {
	defer close(s.closed)
	ticker := time.NewTicker(10 * time.Minute)
	defer ticker.Stop()
	for {
		select {
		case r, ok := <-s.ch:
			if !ok {
				return
			}
			s.insert(r)
		case <-ticker.C:
			s.prune()
		}
	}
}

func (s *Store) insert(r Record) {
	stream := 0
	if r.Stream {
		stream = 1
	}
	_, err := s.db.Exec(`INSERT INTO request_logs
		(method, path, model, target, status, duration_ms, req_bytes, resp_bytes, stream, error, inserted_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		r.Method, r.Path, null(r.Model), null(r.Target), r.Status, r.DurationMS, r.ReqBytes, r.RespBytes, stream, null(r.Error), r.At.UTC().Format(time.RFC3339Nano))
	if err != nil {
		log.Printf("[request-log] insert failed: %v", err)
	}
}

func (s *Store) prune() {
	var cutoff sql.NullInt64
	err := s.db.QueryRow(`SELECT id FROM request_logs ORDER BY id DESC LIMIT 1 OFFSET ?`, maxRows).Scan(&cutoff)
	if err != nil || !cutoff.Valid {
		return
	}
	_, _ = s.db.Exec(`DELETE FROM request_logs WHERE id <= ?`, cutoff.Int64)
}

func migrate(db *sql.DB) error {
	_, err := db.Exec(`
CREATE TABLE IF NOT EXISTS request_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  method TEXT,
  path TEXT,
  model TEXT,
  target TEXT,
  status INTEGER,
  duration_ms INTEGER,
  req_bytes INTEGER,
  resp_bytes INTEGER,
  stream INTEGER DEFAULT 0,
  error TEXT,
  inserted_at TEXT
);
CREATE INDEX IF NOT EXISTS request_logs_inserted_at ON request_logs(inserted_at);
CREATE INDEX IF NOT EXISTS request_logs_status ON request_logs(status);
`)
	return err
}

func withPragmas(path string) string {
	extra := "_pragma=journal_mode(WAL)&_pragma=busy_timeout(5000)"
	if strings.Contains(path, "?") {
		return path + "&" + extra
	}
	return path + "?" + extra
}

func resolvePath(databaseURL string) (string, error) {
	home, _ := os.UserHomeDir()
	def := filepath.Join(home, ".local", "state", "go-litellm", "go_litellm.db")
	if databaseURL == "" {
		return def, nil
	}
	u := databaseURL
	switch {
	case strings.HasPrefix(u, "postgres://") || strings.HasPrefix(u, "postgresql://"):
		log.Printf("[go-litellm] postgres URL given; request log still uses SQLite at %s", def)
		return def, nil
	case strings.HasPrefix(u, "sqlite://"):
		return strings.TrimPrefix(u, "sqlite://"), nil
	case u == ":memory:":
		return "file:go-litellm-mem?mode=memory&cache=shared", nil
	default:
		return u, nil
	}
}

func null(s string) any {
	if s == "" {
		return nil
	}
	return s
}

// MustOpen opens the store or logs and returns a disconnected store.
func MustOpen(databaseURL string) *Store {
	s, err := Open(databaseURL)
	if err != nil {
		log.Printf("[go-litellm] request log disabled: %v", err)
		return nil
	}
	return s
}

// RedactURL masks passwords in URLs.
func RedactURL(url string) string {
	// user:pass@ → user:****@
	at := strings.Index(url, "@")
	scheme := strings.Index(url, "://")
	if at < 0 || scheme < 0 || at < scheme {
		return url
	}
	creds := url[scheme+3 : at]
	colon := strings.Index(creds, ":")
	if colon < 0 {
		return url
	}
	return url[:scheme+3] + creds[:colon] + ":****" + url[at:]
}

// DefaultPath is the compiled default sqlite location.
func DefaultPath() string {
	p, _ := resolvePath("")
	return p
}
