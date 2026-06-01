#!/usr/bin/env bash
# Rebuild/refresh all 4 graphify knowledge graphs from current source.
# AST-only (`graphify update`) — no LLM/API cost — then re-export html + wiki.
# Run from anywhere: bash audit-findings/rebuild-graphs.sh
#
# Graph locations and the source subtree each covers:
#   ./graphify-out                    -> apps/circle-spaces (built from repo root)
#   apps/circle-homepages/graphify-out
#   apps/my-circles/graphify-out
#   packages/graphify-out
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

# graphify is a global CLI; `update <path>` re-extracts code and updates graph.json.
# Each graph's own dir is where its graphify-out lives, so we run update with cwd
# set to that dir and pass "." (matches how each graph was originally built).
declare -a dirs=(
	"$root"                          # circle-spaces (root-built)
	"$root/apps/circle-homepages"
	"$root/apps/my-circles"
	"$root/packages"
)

for d in "${dirs[@]}"; do
	if [ -f "$d/graphify-out/graph.json" ]; then
		echo "== refreshing graph: ${d/$root/.} =="
		( cd "$d" && graphify update . 2>&1 | tail -4 && graphify export html >/dev/null 2>&1 && graphify export wiki >/dev/null 2>&1 ) \
			&& echo "   ok" || echo "   WARN: refresh failed for $d"
	else
		echo "== skip (no graph yet): ${d/$root/.} =="
	fi
done
echo "Done. Open any graphify-out/graph.html or query with: cd <dir> && graphify query \"<question>\""
