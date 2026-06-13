#!/usr/bin/env bash
set -euo pipefail

root="${1:-$(pwd)}"
status=0

extract_subdirs() {
  local file=$1
  awk '
    $1 == "SUBDIRS" {
      sub(/^[[:space:]]*SUBDIRS[[:space:]]*:=[[:space:]]*/, "")
      gsub(/^[[:space:]]+|[[:space:]]+$/, "")
      if (length($0) > 0) print $0
    }
  ' "$file"
}

while IFS= read -r -d '' makefile; do
  dir=${makefile%/Makefile}
  parent=${dir%/*}

  # If this Makefile sits directly under root, ensure root includes it.
  if [ "$parent" = "." ]; then
    continue
  fi

  parent_makefile="$parent/Makefile"
  if [ -f "$parent_makefile" ]; then
    listed=$(extract_subdirs "$parent_makefile")
    declared_dir="${dir##*/}"

    if [ -n "$listed" ]; then
      if ! grep -qw "$declared_dir" <<< "$listed"; then
        echo "[MISSING-FROM-PARENT] ${parent_makefile}: '${declared_dir}' is present at '${dir}/Makefile' but not in SUBDIRS"
        status=1
      fi
    else
      echo "[MISSING-SUBDIRS] ${parent_makefile}: has no SUBDIRS declaration"
      status=1
    fi
  fi
done < <(find "$root" -name Makefile -not -path "$root/mk/*" -print0 | sort -z)

while IFS= read -r parent_makefile; do
  listed=$(extract_subdirs "$parent_makefile")
  [ -z "$listed" ] && continue

  parent_dir=${parent_makefile%/Makefile}
  if [ "$parent_dir" = "." ]; then
    continue
  fi

  read -r -a children <<< "$listed"
  for child in "${children[@]}"; do
    if [ ! -f "$parent_dir/$child/Makefile" ]; then
      echo "[MISSING-CHILD] ${parent_makefile}: listed child '${child}' has no Makefile at '${parent_dir}/${child}/Makefile'"
      status=1
    fi
  done
done < <(find "$root" -path "$root/mk" -prune -o -name Makefile -print)

if [ $status -eq 0 ]; then
  echo "Makefile tree structure is consistent."
fi

exit $status
