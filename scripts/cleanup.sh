#!/usr/bin/env bash

# Function to print usage
usage() {
	echo "Usage: $0 [-l] [-r] [-v]"
	echo "  -l  List directories that should be considered for removal"
	echo "  -r  Remove directories that are no longer under a mounted device"
	echo "  -v  Verbose mode - show detailed debugging information"
	exit 1
}

# Parse command-line arguments
while getopts "lrv" opt; do
	case ${opt} in
	l)
		list_only=true
		;;
	r)
		remove=true
		;;
	v)
		verbose=true
		;;
	*)
		usage
		;;
	esac
done

# Ensure at least one action is specified
if [ -z "$list_only" ] && [ -z "$remove" ]; then
	usage
fi

echo "Checking directories in /persist..."

# Get a list of all currently mounted devices that contain /persist in their mount point,
# excluding the /persist mount itself and including subvol=/persist
mounted_devices=$(mount | grep '/persist' | grep -v ' on /persist ' | awk '{print "/persist" $3}')
[ "$verbose" = true ] && echo "Mounted devices: $mounted_devices"

# Array to hold symlinked directories
symlinked_dirs=()

# Array to track directories marked for removal
to_remove=()

# Array to track safe directories
safe_dirs=()

# Additional array to hold user-specified safe directories
user_safe_dirs=("/persist/passwords")

# Function to check if a directory is symlinked elsewhere
check_symlink_target() {
	local dir="$1"
	# Remove /persist from the path to get the relative path
	local relative_path="${dir#/persist}"

	# Check if the relative path is symlinked somewhere else
	if [ -L "$relative_path" ]; then
		return 0 # Indicate it's a symlinked directory
	fi
	return 1 # Not a symlink
}

# Function to handle directories and check if they should be kept or removed
handle_directory() {
	local dir="$1"
	local keep=false

	# Check if the directory is in the user-safe directories list
	for safe_dir in "${user_safe_dirs[@]}"; do
		if [[ "$dir" == "$safe_dir" ]]; then
			safe_dirs+=("$dir")
			keep=true
			[ "$verbose" = true ] && echo "[KEEP] Directory $dir is in the user-safe list and marked as safe."
			break # No need to check further
		fi
	done

	# First, check if the directory is symlinked elsewhere
	if check_symlink_target "$dir"; then
		symlinked_dirs+=("$dir") # Add the symlinked directory to the list of symlinked directories
		safe_dirs+=("$dir")      # Mark it as safe
		keep=true
		[ "$verbose" = true ] && echo "[KEEP] Directory $dir is symlinked and marked as safe."
	fi

	# Check if the directory is under any of the mounted devices (i.e., is part of a "parent")
	for device in $mounted_devices; do
		if [[ "$dir" == "$device"* ]]; then
			safe_dirs+=("$dir") # Mark it as safe
			keep=true
			[ "$verbose" = true ] && echo "[KEEP] Directory $dir is under a mounted device and marked as safe."
			break
		fi
	done

	# Now, check if the directory is part of any symlinked directories (children of symlinked directories are safe)
	for symlink_dir in "${symlinked_dirs[@]}"; do
		if [[ "$dir" == "$symlink_dir"* ]]; then
			safe_dirs+=("$dir") # Mark it as safe
			keep=true
			[ "$verbose" = true ] && echo "[KEEP] Directory $dir is under a symlinked directory and marked as safe."
			break
		fi
	done

	# If the directory is not marked as safe, add it to the to_remove list
	if [ "$keep" = false ]; then
		to_remove+=("$dir")
		# Debugging: check if we're adding to the to_remove array
		[ "$verbose" = true ] && echo "Added to 'to_remove' array: $dir"
	fi
}

# Function to traverse the directories - FIXED to avoid subshell issues
traverse_tree() {
	local dir="$1"

	# Use a while loop that reads directly from find output without pipes
	while IFS= read -r subdir; do
		handle_directory "$subdir"
	done < <(find "$dir" -type d)
}

# Start the traversal from the root of the /persist directory
traverse_tree "/persist"

# Debugging: print the original contents of the arrays
if [ "$verbose" = true ]; then
	echo "Safe directories:"
	for dir in "${safe_dirs[@]}"; do
		echo "  $dir"
	done

	echo "Directories marked for removal (before filtering):"
	for dir in "${to_remove[@]}"; do
		echo "  $dir"
	done
fi

# Filter out directories in to_remove that are parents of any directory in safe_dirs
filtered_to_remove=()
for remove_dir in "${to_remove[@]}"; do
	is_parent=false

	# Check if this remove_dir is a parent of any safe_dir
	for safe_dir in "${safe_dirs[@]}"; do
		# Skip exact matches
		if [ "$remove_dir" = "$safe_dir" ]; then
			continue
		fi

		# Check if remove_dir is a parent of safe_dir (using prefix matching)
		if [[ "$safe_dir" == "$remove_dir"/* ]]; then
			is_parent=true
			[ "$verbose" = true ] && echo "[FILTER] Removing $remove_dir from to_remove because it's a parent of safe directory $safe_dir"
			break
		fi
	done

	# If this directory is not a parent of any safe directory, keep it in to_remove
	if [ "$is_parent" = false ]; then
		filtered_to_remove+=("$remove_dir")
	fi
done

# Replace the original to_remove with the filtered version
to_remove=("${filtered_to_remove[@]}")

# Debugging: print the filtered to_remove array
if [ "$verbose" = true ]; then
	echo "Directories marked for removal (after filtering):"
	for dir in "${to_remove[@]}"; do
		echo "  $dir"
	done
fi

# Final output, listing directories that will be removed
if [ "$list_only" = true ]; then
	if [ ${#to_remove[@]} -eq 0 ]; then
		echo "[INFO] No directories are marked for removal."
	else
		echo "[INFO] Directories marked for removal:"
		for dir in "${to_remove[@]}"; do
			echo "[REMOVE] $dir"
		done
	fi
elif [ "$remove" = true ]; then
	if [ ${#to_remove[@]} -eq 0 ]; then
		echo "[INFO] No directories are marked for removal."
	else
		echo "[INFO] Removing directories..."
		for dir in "${to_remove[@]}"; do
			echo "[REMOVE] Removing directory: $dir"
			# Uncomment the next line to actually remove the directory
			rm -rf "$dir"
		done
	fi
fi

echo "[INFO] Operation complete."
