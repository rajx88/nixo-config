#!/usr/bin/env bash

# Function to print usage
usage() {
	echo "Usage: $0 [-l] [-r] [-v] [-d]"
	echo "  -l  List directories that should be considered for removal"
	echo "  -r  Remove directories that are no longer under a mounted device"
	echo "  -v  Verbose mode - show detailed debugging information"
	echo "  -d  Deep scan - recursively scan all directories (slower but more thorough)"
	exit 1
}

# Parse command-line arguments
while getopts "lrvd" opt; do
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
	d)
		deep=true
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

# For impermanence v2: Get all mounts from /persist subvolume
# Extract the mount points and map them back to /persist paths
mounted_paths=$(mount | grep "subvol=/persist" | grep -v " on /persist " | awk '{print $3}')

# Convert mount points to their /persist equivalents
mounted_devices=""
while IFS= read -r mount_point; do
	# All mounts are from /persist, so just prepend /persist to the mount point
	persist_path="/persist$mount_point"
	mounted_devices="$mounted_devices $persist_path"
done <<< "$mounted_paths"

[ "$verbose" = true ] && echo "Mounted devices (from /persist): $mounted_devices"

# Array to track items marked for removal
to_remove=()

# Additional array to hold user-specified safe directories
user_safe_dirs=("/persist/passwords")

# Get all top-level items in /persist
all_items=$(find /persist -maxdepth 1 -mindepth 1)

# Check each top-level item
for item in $all_items; do
	is_safe=false

	# Check if it's in user-safe list or inside a user-safe directory
	for safe_dir in "${user_safe_dirs[@]}"; do
		if [[ "$item" == "$safe_dir" ]] || [[ "$item" == "$safe_dir"/* ]]; then
			is_safe=true
			[ "$verbose" = true ] && echo "[KEEP] $item is in or under user-safe directory $safe_dir"
			break
		fi
	done

	# Check if it's currently mounted (or a parent of mounted items)
	if [ "$is_safe" = false ]; then
		for mounted in $mounted_devices; do
			if [[ "$mounted" == "$item"* ]]; then
				is_safe=true
				[ "$verbose" = true ] && echo "[KEEP] $item contains mounted path $mounted"
				break
			fi
		done
	fi

	# If not safe, mark for removal
	if [ "$is_safe" = false ]; then
		to_remove+=("$item")
		[ "$verbose" = true ] && echo "[REMOVE] Marking $item for removal"
	fi
done

# For directories that contain mounts, check for stray files/directories
# that aren't part of the mounts
for item in $all_items; do
	# Skip if already marked for removal
	if [[ " ${to_remove[@]} " =~ " ${item} " ]]; then
		continue
	fi
	
	# Only check directories
	if [ ! -d "$item" ]; then
		continue
	fi
	
	echo "[SCAN] Scanning $item for stray files..."
	
	# Determine scan depth
	if [ "$deep" = true ]; then
		# Deep scan: find all items recursively
		depth_arg=""
		echo "[DEEP] Deep scanning $item recursively (this may take a while)..."
	else
		# Shallow scan: only 1 level deep
		depth_arg="-maxdepth 1"
	fi
	
	# Count items for progress
	item_count=0
	total_items=$(find "$item" $depth_arg -mindepth 1 2>/dev/null | wc -l)
	echo "[PROGRESS] Found $total_items items to check in $item"
	
	# Find all items in this directory
	while IFS= read -r subitem; do
		item_count=$((item_count + 1))
		
		# Show progress every 100 items
		if [ $((item_count % 100)) -eq 0 ]; then
			echo "[PROGRESS] Checked $item_count/$total_items items in $item..."
		fi
		
		# Skip if parent directory is already marked for removal
		parent_marked=false
		for marked in "${to_remove[@]}"; do
			if [[ "$subitem" == "$marked"/* ]]; then
				parent_marked=true
				[ "$verbose" = true ] && echo "[SKIP] $subitem - parent $marked already marked"
				break
			fi
		done

		if [ "$parent_marked" = true ]; then
			continue
		fi

		# Skip if subitem is in or under a user-safe directory
		is_safe=false
		for safe_dir in "${user_safe_dirs[@]}"; do
			if [[ "$subitem" == "$safe_dir" ]] || [[ "$subitem" == "$safe_dir"/* ]]; then
				is_safe=true
				[ "$verbose" = true ] && echo "[KEEP] $subitem is in or under user-safe directory $safe_dir"
				break
			fi
		done
		if [ "$is_safe" = true ]; then
			continue
		fi

		is_mounted=false

		# Check if this subitem is a mount, is inside a mounted directory, OR has mounted children
		for mounted in $mounted_devices; do
			# Exact match: this IS a mount
			if [[ "$subitem" == "$mounted" ]]; then
				is_mounted=true
				[ "$verbose" = true ] && echo "[KEEP] $subitem is a mount point"
				break
			# This item is inside a mount
			elif [[ "$subitem" == "$mounted"/* ]]; then
				is_mounted=true
				[ "$verbose" = true ] && echo "[KEEP] $subitem is inside mount $mounted"
				break
			# A mount is inside this item (this item is a parent of a mount)
			elif [[ "$mounted" == "$subitem"/* ]]; then
				is_mounted=true
				[ "$verbose" = true ] && echo "[KEEP] $subitem contains mount $mounted"
				break
			fi
		done

		# If not mounted, it's a stray
		if [ "$is_mounted" = false ]; then
			to_remove+=("$subitem")
			[ "$verbose" = true ] && echo "[REMOVE] Marking stray $subitem for removal"
		fi
	done < <(find "$item" $depth_arg -mindepth 1 2>/dev/null)
	
	echo "[DONE] Finished scanning $item ($item_count items checked)"
done

# Debugging: print the filtered to_remove array
if [ "$verbose" = true ]; then
	if [ ${#to_remove[@]} -eq 0 ]; then
		echo "[INFO] No items are marked for removal."
	else
		echo "[INFO] Items marked for removal:"
		for dir in "${to_remove[@]}"; do
			echo "[REMOVE] $dir"
		done
	fi
fi

# Final output, listing items that will be removed
if [ "$list_only" = true ] && [ "$remove" = true ]; then
	if [ ${#to_remove[@]} -eq 0 ]; then
		echo "[INFO] No items are marked for removal."
	else
		echo "[INFO] Items marked for removal:"
		for item in "${to_remove[@]}"; do
			echo "[REMOVE] $item"
		done
		echo -n "Do you want to delete these items? [y/N]: "
		read confirm
		if [[ "$confirm" =~ ^[Yy]$ ]]; then
			echo "[INFO] Removing items..."
			for item in "${to_remove[@]}"; do
				echo "[REMOVE] Removing: $item"
				rm -rf "$item"
			done
		else
			echo "[INFO] Aborted removal."
		fi
	fi
elif [ "$list_only" = true ]; then
	if [ ${#to_remove[@]} -eq 0 ]; then
		echo "[INFO] No items are marked for removal."
	else
		echo "[INFO] Items marked for removal:"
		for item in "${to_remove[@]}"; do
			echo "[REMOVE] $item"
		done
	fi
elif [ "$remove" = true ]; then
	if [ ${#to_remove[@]} -eq 0 ]; then
		echo "[INFO] No items are marked for removal."
	else
		echo "[INFO] Removing items..."
		for item in "${to_remove[@]}"; do
			echo "[REMOVE] Removing: $item"
			rm -rf "$item"
		done
	fi
fi

echo "[INFO] Operation complete."
