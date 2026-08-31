package gateway

import (
	"bytes"
	"io"
	"log"
	"net/http"
	"strings"

	"github.com/noizu-labs/go-litellm/internal/frontproxy"
)

var hopByHop = map[string]bool{
	"host": true, "connection": true, "keep-alive": true,
	"transfer-encoding": true, "te": true, "trailer": true,
	"upgrade": true, "content-length": true, "accept-encoding": true,
}

var stripResp = map[string]bool{
	"content-encoding": true, "content-length": true, "transfer-encoding": true,
}

func (a *App) passthrough(w http.ResponseWriter, r *http.Request) {
	body := a.jsonBody(r)
	d := a.Rules.Route(r.URL.Path, body)
	a.tag(r, "", d.BaseURL, "")
	url := d.BaseURL + r.URL.RequestURI()
	headers := a.forwardHeaders(r, d.Auth)
	a.forward(w, r, url, headers, a.rawBody(r))
}

func (a *App) forwardTo(w http.ResponseWriter, r *http.Request, url string, headers map[string]string, body []byte) {
	a.forward(w, r, url, headers, body)
}

func (a *App) forwardHeaders(r *http.Request, auth string) map[string]string {
	out := map[string]string{}
	for k, vs := range r.Header {
		if hopByHop[strings.ToLower(k)] {
			continue
		}
		if auth == frontproxy.AuthMasterKey && strings.EqualFold(k, "authorization") {
			continue
		}
		if len(vs) > 0 {
			out[k] = vs[0]
		}
	}
	if auth == frontproxy.AuthMasterKey {
		out["Authorization"] = "Bearer " + a.Settings.MasterKey
	}
	return out
}

func (a *App) forward(w http.ResponseWriter, r *http.Request, url string, headers map[string]string, body []byte) {
	streaming := strings.Contains(r.Header.Get("Accept"), "text/event-stream")
	if streaming {
		a.streamForward(w, r, url, headers, body)
		return
	}
	req, err := http.NewRequest(r.Method, url, bytes.NewReader(body))
	if err != nil {
		a.proxyError(w, r, err)
		return
	}
	for k, v := range headers {
		req.Header.Set(k, v)
	}
	req.Header.Del("Accept-Encoding")
	resp, err := a.httpDo(req)
	if err != nil {
		a.proxyError(w, r, err)
		return
	}
	defer resp.Body.Close()
	copyRespHeaders(w, resp.Header)
	w.WriteHeader(resp.StatusCode)
	_, _ = io.Copy(w, resp.Body)
}

func (a *App) streamForward(w http.ResponseWriter, r *http.Request, url string, headers map[string]string, body []byte) {
	req, err := http.NewRequest(r.Method, url, bytes.NewReader(body))
	if err != nil {
		a.proxyError(w, r, err)
		return
	}
	for k, v := range headers {
		req.Header.Set(k, v)
	}
	req.Header.Del("Accept-Encoding")
	resp, err := a.httpDo(req)
	if err != nil {
		if retryableNet(err) {
			log.Printf("[gateway] stale connection at stream connect — retrying")
			req2, _ := http.NewRequest(r.Method, url, bytes.NewReader(body))
			for k, v := range headers {
				req2.Header.Set(k, v)
			}
			req2.Header.Del("Accept-Encoding")
			resp, err = a.httpDo(req2)
		}
		if err != nil {
			a.proxyError(w, r, err)
			return
		}
	}
	defer resp.Body.Close()
	copyRespHeaders(w, resp.Header)
	w.WriteHeader(resp.StatusCode)
	if f, ok := w.(http.Flusher); ok {
		buf := make([]byte, 32*1024)
		for {
			n, err := resp.Body.Read(buf)
			if n > 0 {
				_, _ = w.Write(buf[:n])
				f.Flush()
			}
			if err != nil {
				return
			}
		}
	}
	_, _ = io.Copy(w, resp.Body)
}

func (a *App) httpDo(req *http.Request) (*http.Response, error) {
	if a.HTTP != nil {
		return a.HTTP.Do(req)
	}
	return http.DefaultClient.Do(req)
}

func copyRespHeaders(w http.ResponseWriter, h http.Header) {
	for k, vs := range h {
		if stripResp[strings.ToLower(k)] {
			continue
		}
		for _, v := range vs {
			w.Header().Add(k, v)
		}
	}
}

func (a *App) proxyError(w http.ResponseWriter, r *http.Request, err error) {
	log.Printf("[gateway] upstream forward error: %v", err)
	a.tag(r, "", "", err.Error())
	writeJSON(w, 502, map[string]any{
		"type":  "error",
		"error": map[string]any{"type": "api_error", "message": "upstream request failed: " + err.Error()},
	})
}

func retryableNet(err error) bool {
	if err == nil {
		return false
	}
	s := strings.ToLower(err.Error())
	return strings.Contains(s, "connection reset") ||
		strings.Contains(s, "eof") ||
		strings.Contains(s, "broken pipe") ||
		strings.Contains(s, "use of closed network connection")
}
