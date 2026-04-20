#!/usr/bin/env bash
# Usage: ./run_variant.sh <variant-name> <n> [prompt-file]
# Runs `claude -p` n times in parallel, saves to outputs/<variant-name>/sample_<i>.txt.
# If prompt-file is omitted, invokes without --system-prompt (baseline).

set -euo pipefail

variant="${1:?variant name required}"
n="${2:?sample count required}"
prompt_file="${3:-}"

outdir="outputs/${variant}"
mkdir -p "${outdir}"

run_one() {
  local i="$1"
  local outfile="${outdir}/sample_${i}.txt"
  if [[ -n "${prompt_file}" ]]; then
    echo "Write a haiku." | claude -p --model claude-sonnet-4-6 --tools "" \
      --system-prompt "$(cat "${prompt_file}")" > "${outfile}"
  else
    echo "Write a haiku." | claude -p --model claude-sonnet-4-6 --tools "" > "${outfile}"
  fi
  echo "  -> ${outfile}"
}

echo "Running variant=${variant} n=${n} prompt=${prompt_file:-<none>}"
pids=()
for ((i=1; i<=n; i++)); do
  run_one "$i" &
  pids+=($!)
done

for pid in "${pids[@]}"; do
  wait "$pid"
done

echo "Done. Samples in ${outdir}/"
