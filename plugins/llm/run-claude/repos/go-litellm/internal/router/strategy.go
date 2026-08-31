package router

import (
	"math/rand"

	"github.com/noizu-labs/go-litellm/internal/jsonx"
)

// Pick chooses one deployment from a non-empty pool.
func Pick(strategy string, pool []map[string]any) map[string]any {
	if len(pool) == 1 {
		return pool[0]
	}
	// Unknown / telemetry-backed strategies fall back to weighted shuffle.
	_ = strategy
	return weightedShuffle(pool)
}

func weightedShuffle(pool []map[string]any) map[string]any {
	if len(pool) == 0 {
		return nil
	}
	weights := make([]float64, len(pool))
	var total float64
	for i, d := range pool {
		w := weight(d)
		weights[i] = w
		total += w
	}
	if total <= 0 {
		return pool[rand.Intn(len(pool))]
	}
	target := rand.Float64() * total
	for i, d := range pool {
		if target <= weights[i] {
			return d
		}
		target -= weights[i]
	}
	return pool[len(pool)-1]
}

func weight(d map[string]any) float64 {
	if lp := jsonx.Nested(d, "litellm_params"); lp != nil {
		if w, ok := jsonx.Float(lp, "weight"); ok && w > 0 {
			return w
		}
	}
	if info := jsonx.Nested(d, "model_info"); info != nil {
		if w, ok := jsonx.Float(info, "weight"); ok && w > 0 {
			return w
		}
	}
	return 1
}
