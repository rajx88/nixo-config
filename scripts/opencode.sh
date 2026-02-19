#!/usr/bin/env bash

set -euo pipefail

usage() {
	echo "Usage: ocd [-d <dir>]..."
	echo
	echo "Options:"
	echo "  -d <dir>  Mount a directory into the container under /workspace/<dirname>"
	echo "            Can be specified multiple times for multiple projects."
	echo "  -h        Show this help message."
	echo
	echo "If no -d flags are given, the current directory is mounted as /workspace."
	exit 0
}

dirs=()

while getopts ":d:h" opt; do
	case $opt in
	d) dirs+=("$(realpath "$OPTARG")") ;;
	h) usage ;;
	\?) echo "Unknown option: -$OPTARG" >&2 && exit 1 ;;
	:) echo "Option -$OPTARG requires an argument." >&2 && exit 1 ;;
	esac
done
shift $((OPTIND - 1))

volume_args=()

if [[ ${#dirs[@]} -eq 0 ]]; then
	volume_args+=(-v "$(pwd)":/workspace)
else
	for dir in "${dirs[@]}"; do
		if [[ ! -d "$dir" ]]; then
			echo "Error: '$dir' is not a directory." >&2
			exit 1
		fi
		name=$(basename "$dir")
		volume_args+=(-v "$dir":"/workspace/$name")
	done
fi

docker run -it --rm \
	-w /workspace \
	"${volume_args[@]}" \
	-v "$HOME/.config/opencode":/root/.config/opencode \
	-v "$HOME/.local/share/opencode":/root/.local/share/opencode \
	ghcr.io/anomalyco/opencode "$@"
