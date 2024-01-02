import subprocess
import os
import time
import random
import sys

IMAGE_EXTENSIONS =  ['.gif', '.jpg', '.jpeg', '.png']

def change_wallpaper(image_path):
    try:
        # try:
        #     # killall swaybg, this is needed otherwise swaybg instances will stack up
        #     with subprocess.Popen(["killall", "swaybg"]) as p: p.wait()
        # except Exception as e:
        #     print("something wong killing swaybg: " + str(e))

        result, err = subprocess.Popen(["pgrep", "swaybg"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
        print(result)

        normalized = result.decode('ascii')
        processes = normalized.split('\n')
        processes = [process for process in processes if process]
        print(processes)

        print("Changing wallpaper to " + image_path)
        command = ["swaybg"]
        command.extend(["-i", image_path])
        command.extend(["-m", "fill"])
        # this will create a process to set the new background
        subprocess.Popen(command)
        # wait a bit to make sure the new background is set
        # no bad side effects to wait a bit longer
        time.sleep(10)
        # clean up old swaybg processes
        for process in processes:
            try:
                with subprocess.Popen(["kill", process]) as p: p.wait()
            except Exception as e:
                print("something wong killing swaybg: " + str(e))

    except Exception as e:
        print("Error changing wallpaper: " + str(e))

def get_image_paths(root_folder):
    image_paths = []
    for root, directories, files in os.walk(root_folder):
        if  root != root_folder:
            continue
 
        for filename in files:
            if has_image_extension(filename):
                image_paths.append(os.path.join(root, filename))

    return image_paths

def has_image_extension(file_path):
    ext = os.path.splitext(file_path)[1].lower()
    return ext in IMAGE_EXTENSIONS

def get_random_file(folder):
    try:
        image_paths = get_image_paths(folder)
        return random.choice(image_paths)
    except Exception as e:
        print("Error getting random file: " + str(e))
        return None

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: wall-changer.py <folder>")
        sys.exit(1)

    directory = sys.argv[1]
    print(directory)

    file = get_random_file(directory)

    if file is not None:
        change_wallpaper(file)
