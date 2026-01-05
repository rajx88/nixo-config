#!/usr/bin/env bash

WALLPAPER_DIR="$XDG_DATA_HOME/wallpapers/"
CURRENT_WALL=$(hyprctl hyprpaper listloaded)

echo "Current Wallpaper: $CURRENT_WALL"
echo "Wallpaper Directory: $WALLPAPER_DIR"

if [[ -z "$CURRENT_WALL" ]]; then
	echo "Error: Failed to get current wallpaper!"
	exit 1
fi

CURRENT_BASENAME=$(basename -- "$CURRENT_WALL")

echo "Current Wallpaper Basename: $CURRENT_BASENAME"

# Debugging: Check contents of the wallpaper directory
echo "Available Wallpapers:"
find "$WALLPAPER_DIR" -type f -o -type l

# Find wallpapers excluding the current one, including symlinks
WALLPAPER=$(find "$WALLPAPER_DIR" -type f -o -type l ! -iname "$CURRENT_BASENAME" | shuf -n 1)

echo "Selected Wallpaper: $WALLPAPER"

if [[ -z "$WALLPAPER" ]]; then
	echo "Error: No other wallpapers found!"
	exit 1
fi

# Apply the selected wallpaper using reload
hyprctl hyprpaper wallpaper ",$WALLPAPER"
