#!/usr/bin/env bash
set -euo pipefail

SRC="${1:-$HOME/Downloads/tailwindplus}"
DEST="src/components/tailwind-plus"

declare -A SECTION_MAP=(
  ["application-ui-v4"]="app-ui"
  ["marketing-v4"]="marketing"
  ["ecommerce-v4"]="ecommerce"
)

to_pascal() {
  local slug="$1"
  local num="${slug%%-*}"
  local rest="${slug#*-}"
  local pascal=""
  IFS='-' read -ra parts <<< "$rest"
  for part in "${parts[@]}"; do
    pascal+="$(echo "${part:0:1}" | tr '[:lower:]' '[:upper:]')${part:1}"
  done
  local result="${pascal}${num}"
  # Prefix with "N" if starts with a digit (invalid JS identifier)
  if [[ "$result" =~ ^[0-9] ]]; then
    result="N${result}"
  fi
  echo "$result"
}

echo "=== Tailwind Plus Import ==="
echo "Source: $SRC"
echo "Dest:   $DEST"
echo ""

total=0
mkdir -p "$DEST"

for section_dir in "$SRC"/*/react; do
  [ -d "$section_dir" ] || continue
  section_base=$(basename "$(dirname "$section_dir")")
  target_section="${SECTION_MAP[$section_base]:-}"
  [ -z "$target_section" ] && { echo "SKIP unknown section: $section_base"; continue; }

  echo "--- $section_base → $target_section ---"

  find "$section_dir" -name '*.jsx' -type f | sort | while read -r jsx_file; do
    rel="${jsx_file#$section_dir/}"
    category_path="${rel%/*}"
    base_name="${rel##*/}"
    base_name="${base_name%.jsx}"
    # Normalize: replace dots and underscores with dashes for consistent slug
    base_name="${base_name//./-}"
    base_name="${base_name//_/-}"

    component_name=$(to_pascal "$base_name")
    target_dir="$DEST/$target_section/$category_path"
    target_file="$target_dir/${component_name}.tsx"

    mkdir -p "$target_dir"

    {
      echo "// @ts-nocheck"
      if ! head -1 "$jsx_file" | grep -q "'use client'"; then
        echo "'use client'"
      fi
      echo ""
      sed -E "s/export default function [A-Za-z0-9_]+/export function ${component_name}/" "$jsx_file" |
        sed -E "s/^export default /export /"
    } > "$target_file"

    total=$((total + 1))
  done
done

echo ""
echo "=== Copied $total files ==="
echo ""

echo "=== Generating barrel exports ==="

find "$DEST" -type d | sort | while read -r dir; do
  tsx_files=()
  while IFS= read -r f; do
    tsx_files+=("$f")
  done < <(find "$dir" -maxdepth 1 -name '*.tsx' -type f | sort)

  subdirs=()
  while IFS= read -r d; do
    subdirs+=("$d")
  done < <(find "$dir" -maxdepth 1 -mindepth 1 -type d | sort)

  [ ${#tsx_files[@]} -eq 0 ] && [ ${#subdirs[@]} -eq 0 ] && continue

  index_file="$dir/index.ts"
  > "$index_file"

  # For directories containing subdirs, use namespace imports to avoid collisions
  for sub in "${subdirs[@]}"; do
    sub_name=$(basename "$sub")
    # Convert kebab-case to PascalCase for namespace
    ns=""
    IFS='-' read -ra ns_parts <<< "$sub_name"
    for p in "${ns_parts[@]}"; do
      ns+="$(echo "${p:0:1}" | tr '[:lower:]' '[:upper:]')${p:1}"
    done
    # Prefix with "N" if starts with digit
    if [[ "$ns" =~ ^[0-9] ]]; then
      ns="N${ns}"
    fi
    echo "export * as ${ns} from './${sub_name}';" >> "$index_file"
  done

  for tsx in "${tsx_files[@]}"; do
    fname=$(basename "$tsx" .tsx)
    echo "export { ${fname} } from './${fname}';" >> "$index_file"
  done

  echo "  INDEX $index_file (${#tsx_files[@]} components, ${#subdirs[@]} subdirs)"
done

echo ""
echo "=== Done ==="
