// Package jsonx holds map helpers for the loosely-typed LiteLLM config / request
// bodies (the Elixir side is maps of strings).
package jsonx

import (
	"encoding/json"
	"fmt"
	"strings"
)

// AsMap returns v as a string-keyed map, or nil.
func AsMap(v any) map[string]any {
	if v == nil {
		return nil
	}
	switch m := v.(type) {
	case map[string]any:
		return m
	case map[any]any:
		out := make(map[string]any, len(m))
		for k, val := range m {
			out[fmt.Sprint(k)] = val
		}
		return out
	default:
		return nil
	}
}

// Str returns a string field, or "".
func Str(m map[string]any, key string) string {
	if m == nil {
		return ""
	}
	switch v := m[key].(type) {
	case string:
		return v
	case fmt.Stringer:
		return v.String()
	default:
		return ""
	}
}

// Bool returns a boolean field. JSON true, and the strings true/1/yes/on.
func Bool(m map[string]any, key string) bool {
	if m == nil {
		return false
	}
	switch v := m[key].(type) {
	case bool:
		return v
	case string:
		s := strings.ToLower(strings.TrimSpace(v))
		return s == "true" || s == "1" || s == "yes" || s == "on"
	default:
		return false
	}
}

// Float returns a numeric field as float64.
func Float(m map[string]any, key string) (float64, bool) {
	if m == nil {
		return 0, false
	}
	switch v := m[key].(type) {
	case float64:
		return v, true
	case float32:
		return float64(v), true
	case int:
		return float64(v), true
	case int64:
		return float64(v), true
	case json.Number:
		f, err := v.Float64()
		return f, err == nil
	default:
		return 0, false
	}
}

// Int returns a numeric field as int.
func Int(m map[string]any, key string) (int, bool) {
	f, ok := Float(m, key)
	if !ok {
		return 0, false
	}
	return int(f), true
}

// Nested returns m[key] as a map.
func Nested(m map[string]any, key string) map[string]any {
	if m == nil {
		return nil
	}
	return AsMap(m[key])
}

// Clone shallow-copies a map.
func Clone(m map[string]any) map[string]any {
	if m == nil {
		return map[string]any{}
	}
	out := make(map[string]any, len(m))
	for k, v := range m {
		out[k] = v
	}
	return out
}

// DeepMerge merges b into a copy of a. Nested maps merge recursively.
func DeepMerge(a, b map[string]any) map[string]any {
	out := Clone(a)
	for k, v := range b {
		if vm := AsMap(v); vm != nil {
			if existing := AsMap(out[k]); existing != nil {
				out[k] = DeepMerge(existing, vm)
				continue
			}
		}
		out[k] = v
	}
	return out
}

// StringKeys recursively converts map[any]any (yaml.v3) into map[string]any.
func StringKeys(v any) any {
	switch t := v.(type) {
	case map[string]any:
		out := make(map[string]any, len(t))
		for k, val := range t {
			out[k] = StringKeys(val)
		}
		return out
	case map[any]any:
		out := make(map[string]any, len(t))
		for k, val := range t {
			out[fmt.Sprint(k)] = StringKeys(val)
		}
		return out
	case []any:
		out := make([]any, len(t))
		for i, val := range t {
			out[i] = StringKeys(val)
		}
		return out
	default:
		return v
	}
}

// DropNil removes keys whose value is nil.
func DropNil(m map[string]any) map[string]any {
	out := make(map[string]any, len(m))
	for k, v := range m {
		if v != nil {
			out[k] = v
		}
	}
	return out
}

// EncodeJSON encodes v, returning "{}" on error.
func EncodeJSON(v any) []byte {
	b, err := json.Marshal(v)
	if err != nil {
		return []byte("{}")
	}
	return b
}
