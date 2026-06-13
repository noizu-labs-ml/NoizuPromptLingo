#!/usr/bin/env bash
# Exercise every modality against a running gateway.
# Usage: BASE_URL=http://127.0.0.1:8080 API_KEY=local-dev-key ./smoke-test.sh
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
API_KEY="${API_KEY:-${MODAL_GENAI_API_KEY:-local-dev-key}}"
AUTH=(-H "Authorization: Bearer ${API_KEY}")
JSON=(-H "Content-Type: application/json")
OUT="${OUT:-generated}"
mkdir -p "$OUT"

say() { printf "\n=== %s ===\n" "$1"; }

say "health"; curl -fsS "$BASE_URL/health"; echo
say "models"; curl -fsS "${AUTH[@]}" "$BASE_URL/v1/models"; echo

say "chat (qwen3.6)"
curl -fsS "${AUTH[@]}" "${JSON[@]}" "$BASE_URL/v1/chat/completions" \
  -d '{"model":"qwen3.6","messages":[{"role":"user","content":"One sentence on Modal."}]}'; echo

say "vision chat (glm-4.6v)"
curl -fsS "${AUTH[@]}" "${JSON[@]}" "$BASE_URL/v1/chat/completions" \
  -d '{"model":"glm-4.6v","messages":[{"role":"user","content":"Describe a sunset."}]}'; echo

say "embeddings"
curl -fsS "${AUTH[@]}" "${JSON[@]}" "$BASE_URL/v1/embeddings" \
  -d '{"model":"embed","input":["hello","world"]}'; echo

say "image (z-image)"
curl -fsS "${AUTH[@]}" "${JSON[@]}" "$BASE_URL/v1/images/generations" \
  -d '{"model":"z-image","prompt":"a matte black espresso machine, product photo","size":"1024x1024"}' \
  | python3 -c 'import sys,json,base64;d=json.load(sys.stdin)["data"][0];open("'"$OUT"'/image.png","wb").write(base64.b64decode(d["b64_json"]));print("wrote '"$OUT"'/image.png")'

say "tts (kokoro)"
curl -fsS "${AUTH[@]}" "${JSON[@]}" "$BASE_URL/v1/audio/speech" \
  -d '{"model":"kokoro","input":"Hello from Modal.","voice":"af_heart","response_format":"wav"}' \
  -o "$OUT/speech.wav"; echo "wrote $OUT/speech.wav"

say "music (ace-step)"
curl -fsS "${AUTH[@]}" "${JSON[@]}" "$BASE_URL/v1/audio/generations" \
  -d '{"model":"ace-step","prompt":"upbeat lo-fi hip hop","duration_seconds":10}' \
  -o "$OUT/music.wav"; echo "wrote $OUT/music.wav"

say "sfx (stable-audio)"
curl -fsS "${AUTH[@]}" "${JSON[@]}" "$BASE_URL/v1/audio/generations" \
  -d '{"model":"stable-audio","prompt":"thunderclap and rain","duration_seconds":8}' \
  -o "$OUT/sfx.wav"; echo "wrote $OUT/sfx.wav"

say "stt (whisper)"
if [[ -f "$OUT/speech.wav" ]]; then
  curl -fsS "${AUTH[@]}" "$BASE_URL/v1/audio/transcriptions" \
    -F model=whisper -F file=@"$OUT/speech.wav"; echo
fi

say "video (wan) — returns a task"
curl -fsS "${AUTH[@]}" "${JSON[@]}" "$BASE_URL/v1/video/generations" \
  -d '{"model":"wan","prompt":"a paper plane gliding over a city","size":"832x480","duration_seconds":4}'; echo

say "3d (trellis) — image-to-3d task"
curl -fsS "${AUTH[@]}" "${JSON[@]}" "$BASE_URL/v1/3d/generations" \
  -d '{"model":"trellis","image":"generated/image.png","response_format":"glb"}'; echo

echo; echo "smoke complete."
