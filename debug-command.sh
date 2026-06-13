#!/usr/bin/env bash
# Debug script to test different approaches for capturing pytest output

echo "=== Testing different approaches for test-errors command ==="
echo ""

# Approach 1: Direct pipe (baseline - known to work)
approach1() {
    echo "--- Approach 1: Direct pipe ---"
    uv run pytest tests/ --tb=no -q 2>&1 | grep -E '^FAILED|^ERROR' | sed 's/FAILED /❌ /; s/ERROR /⚠️ /' || echo "✅ (no failures found)"
}

# Approach 2: Variable capture with echo
approach2() {
    echo "--- Approach 2: Variable + echo ---"
    output=$(uv run pytest tests/ --tb=no -q 2>&1)
    exitcode=$?
    echo "Exit code: $exitcode, Output length: ${#output}"
    echo "$output" | grep -E '^FAILED|^ERROR' | sed 's/FAILED /❌ /; s/ERROR /⚠️ /' || echo "✅ (no grep match)"
}

# Approach 3: Variable capture with printf
approach3() {
    echo "--- Approach 3: Variable + printf ---"
    output=$(uv run pytest tests/ --tb=no -q 2>&1)
    exitcode=$?
    echo "Exit code: $exitcode"
    printf '%s\n' "$output" | grep -E '^FAILED|^ERROR' | sed 's/FAILED /❌ /; s/ERROR /⚠️ /' || echo "✅ (no grep match)"
}

# Approach 4: Temp file
approach4() {
    echo "--- Approach 4: Temp file ---"
    tmpfile=$(mktemp)
    uv run pytest tests/ --tb=no -q > "$tmpfile" 2>&1
    exitcode=$?
    echo "Exit code: $exitcode"
    grep -E '^FAILED|^ERROR' "$tmpfile" | sed 's/FAILED /❌ /; s/ERROR /⚠️ /' || echo "✅ (no failures)"
    rm -f "$tmpfile"
}

# Approach 5: Process substitution
approach5() {
    echo "--- Approach 5: Process substitution ---"
    grep -E '^FAILED|^ERROR' <(uv run pytest tests/ --tb=no -q 2>&1) | sed 's/FAILED /❌ /; s/ERROR /⚠️ /' || echo "✅ (no failures)"
}

# Approach 6: Heredoc from variable
approach6() {
    echo "--- Approach 6: Heredoc ---"
    output=$(uv run pytest tests/ --tb=no -q 2>&1)
    exitcode=$?
    echo "Exit code: $exitcode"
    grep -E '^FAILED|^ERROR' <<< "$output" | sed 's/FAILED /❌ /; s/ERROR /⚠️ /' || echo "✅ (no grep match)"
}

# Approach 7: Named pipe (FIFO)
approach7() {
    echo "--- Approach 7: Named pipe ---"
    fifo=$(mktemp -u)
    mkfifo "$fifo"
    uv run pytest tests/ --tb=no -q > "$fifo" 2>&1 &
    grep -E '^FAILED|^ERROR' "$fifo" | sed 's/FAILED /❌ /; s/ERROR /⚠️ /' || echo "✅ (no failures)"
    rm -f "$fifo"
}

# Approach 8: tee to /dev/null and file
approach8() {
    echo "--- Approach 8: tee approach ---"
    tmpfile=$(mktemp)
    uv run pytest tests/ --tb=no -q 2>&1 | tee "$tmpfile" > /dev/null
    grep -E '^FAILED|^ERROR' "$tmpfile" | sed 's/FAILED /❌ /; s/ERROR /⚠️ /' || echo "✅ (no failures)"
    rm -f "$tmpfile"
}

# Approach 9: Check if ANSI codes interfere (strip them)
approach9() {
    echo "--- Approach 9: Strip ANSI codes (--color=no) ---"
    uv run pytest tests/ --tb=no -q --color=no 2>&1 | grep -E '^FAILED|^ERROR' | sed 's/FAILED /❌ /; s/ERROR /⚠️ /' || echo "✅ (no failures)"
}

# Approach 10: Using awk instead of grep+sed
approach10() {
    echo "--- Approach 10: awk only ---"
    uv run pytest tests/ --tb=no -q 2>&1 | awk '/^FAILED/ {gsub(/^FAILED /, "❌ "); print} /^ERROR/ {gsub(/^ERROR /, "⚠️ "); print}' || echo "✅ (no failures)"
}

# Approach 11: PIPESTATUS check
approach11() {
    echo "--- Approach 11: Direct pipe with PIPESTATUS ---"
    uv run pytest tests/ --tb=no -q 2>&1 | grep -E '^FAILED|^ERROR' | sed 's/FAILED /❌ /; s/ERROR /⚠️ /'
    echo "PIPESTATUS: ${PIPESTATUS[@]}"
}

# Approach 12: Using script -q for pseudo-tty
approach12() {
    echo "--- Approach 12: script -c wrapper ---"
    script -q -c "uv run pytest tests/ --tb=no -q 2>&1" /dev/null | grep -E '^FAILED|^ERROR' | sed 's/FAILED /❌ /; s/ERROR /⚠️ /' || echo "✅ (no failures)"
}

# Run all approaches
echo ""
echo "Running all approaches..."
echo ""

for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
    echo ""
    approach$i || echo "(approach $i failed with exit code $?)"
    echo ""
done

echo "=== Debug complete ==="
