#!/usr/bin/env python3
# """
# Command to run: python3 davocache.py /source /destination 7 30

# That would move all files between 7 and 30 days old and delete source files after migration is complete
# """

import os
import shutil
import time
import sys

def is_file_within_age_range(filepath, min_days, max_days):
    """
    Check if the file's modification time is within the specified age range.

    :param filepath: Path to the file
    :param min_days: Minimum file age in days
    :param max_days: Maximum file age in days
    :return: True if the file's age is within the range, False otherwise
    """
    current_time = time.time()
    file_mtime = os.stat(filepath).st_mtime
    file_age_days = (current_time - file_mtime) / (60 * 60 * 24)  # Convert seconds to days
    return min_days <= file_age_days <= max_days

def copy_file_with_metadata(src_file, dest_file):
    """
    Copy a file while retaining its metadata, permissions, and ownership.

    :param src_file: Source file path
    :param dest_file: Destination file path
    """
    shutil.copy2(src_file, dest_file)  # Copy file with metadata (timestamps)
    src_stat = os.stat(src_file)

def migrate_files(src, dest, min_days, max_days):
    """
    Migrate files from a source directory to a destination directory
    and recreate hardlinks at the destination based on the source's
    hardlink structure, only moving files within a specific age range.

    :param src: Source directory path
    :param dest: Destination directory path
    :param min_days: Minimum file age in days
    :param max_days: Maximum file age in days
    :return: A list of successfully processed source files
    """
    inode_to_dest_file = {}
    processed_files = []  # List to track successfully processed files

    for root, dirs, files in os.walk(src):
        # Determine relative path from source to current directory
        rel_path = os.path.relpath(root, src)
        dest_dir = os.path.join(dest, rel_path)

        for file in files:
            src_file = os.path.join(root, file)
            dest_file = os.path.join(dest_dir, file)

            # Check if the file is within the age range
            if not is_file_within_age_range(src_file, min_days, max_days):
##                print(f"Skipping file (out of age range): {src_file}")
                continue

            # Create directories in the destination
            print(f"Making directory: {dest_dir}")
            os.makedirs(dest_dir, exist_ok=True)

            # Get the inode of the source file
            inode = os.stat(src_file).st_ino

            # Skip if the file already exists in the destination with the same size
            if os.path.exists(dest_file):
                src_stat = os.stat(src_file)
                dest_stat = os.stat(dest_file)
                if src_stat.st_size == dest_stat.st_size:
                    print(f"Skipping existing file: {dest_file}")
                    inode_to_dest_file[inode] = dest_file  # Map the inode to the existing file
                    processed_files.append(src_file)
                    continue

            if inode in inode_to_dest_file:
                # If inode is already processed, create a hard link
                existing_dest_file = inode_to_dest_file[inode]
                os.link(existing_dest_file, dest_file)
                print(f"Hardlinked: {dest_file} -> {existing_dest_file}")
            else:
                # Copy the file to the destination and track its inode
                # shutil.copy2(src_file, dest_file)  # Copy with metadata
                copy_file_with_metadata(src_file, dest_file)
                inode_to_dest_file[inode] = dest_file
                print(f"Copied: {src_file} -> {dest_file}")

            processed_files.append(src_file)

    return processed_files

def delete_source_files(processed_files):
    """
    Delete the source files that were successfully migrated
    and remove any empty directories.

    :param processed_files: List of successfully processed source files
    """
    for src_file in processed_files:
        os.remove(src_file)
        print(f"Deleted source file: {src_file}")

    # Remove empty directories
    for root, dirs, files in os.walk(os.path.dirname(processed_files[0]), topdown=False):
        for dir_ in dirs:
            dir_path = os.path.join(root, dir_)
            if not os.listdir(dir_path):  # Directory is empty
                os.rmdir(dir_path)
                print(f"Removed empty directory: {dir_path}")

if __name__ == "__main__":
    import argparse

    # Argument parsing
    parser = argparse.ArgumentParser(description="Migrate files and preserve hardlinks, only moving files within a specific age range. Deletes source files after successful migration.")
    parser.add_argument("source", help="Path to the source directory")
    parser.add_argument("destination", help="Path to the destination directory")
    parser.add_argument("min_days", type=int, help="Minimum file age in days")
    parser.add_argument("max_days", type=int, help="Maximum file age in days")
    args = parser.parse_args()

    try:
        processed_files = migrate_files(args.source, args.destination, args.min_days, args.max_days)
        delete_source_files(processed_files)
        print(f"Migration and hardlink recreation completed successfully from '{args.source}' to '{args.destination}'.")
    # Ignore IndexError that occurs if there are no files to move
    except IndexError as e:
        print(f"No files to move: {e}")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
