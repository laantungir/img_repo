#!/bin/bash

# This script converts images to black and white 
# and then renames them with their hash function


# Set the source directory
src_dir="color"

# Set the destination directory
dst_dir="docs"

# Loop through all files in the source directory
for file in "$src_dir"/*; do
  # Check if it's a regular file (not a directory)
  if [ -f "$file" ]; then
    # Convert the file to black and white using ImageMagick
    convert "$file" -colorspace Gray "$dst_dir/${file##*/}"

    
    # Copy the converted file to the destination directory
    # cp "$dst_dir/${file##*/}" "$dst_dir"

    # Move the converted file to the destination directory
    rm "${src_dir}/${file##*/}" 
  fi
done

# remove images.json

rm docs/images.json

# Set the directory where the script is located
SCRIPT_DIR=$(dirname "$0")
BW_DIR="${SCRIPT_DIR}/docs"

# Function to rename files using their sha-256 hash
rename_file() {
  local file="$1"
  local name_without_ext="${file%.*}"
  local ext="${file##*.}"
  local hash=$(sha256sum "${file}" | cut -d' ' -f1)
  mv "${file}" "./docs/${hash}.${ext}"
}

# Rename all files in the docs subdirectory
for FILE in "docs/"*; do
  rename_file "$FILE"
done

# # Create a JSON file with information about each image
cd "${SCRIPT_DIR}"/docs/


# # Start a json file
echo "export const jsonImg = {" > images.mjs

for FILE in $(ls -1 *.{jpg,jpeg,png,gif,bmp}); 
  do
    # Echo out the filename of the image
    echo "3>" "$FILE"

    SIZE=$(stat --format="%s" "$FILE")
    DIMENSIONS=$(identify -format "%w,%H" "$FILE")
    TIMESTAMP=$(date +%s)
    echo "\"$FILE\":{
        \"size\": $SIZE,
        \"dimensions\": [$DIMENSIONS],
        \"uploaded\": $TIMESTAMP,
        \"posted\": \"\" }" >> images.mjs

    echo "" >> images.mjs
    echo "," >> images.mjs
  done

# Remove the trailing comma and close out the json
head -n -1 images.mjs > temp.txt ; mv temp.txt images.mjs
echo "}" >> images.mjs

git add .; 
git commit --allow-empty-message -m '' ;
git push origin main;