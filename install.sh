#!/bin/bash

# Set source and target directories, default: all fonts
nerdfonts_root_dir="${PWD}/fonts"
nerdfonts_dirs=("$nerdfonts_root_dir")

# Accept font / directory names, to avoid installing all fonts
if [ ! -z "$*" ]; then
  nerdfonts_dirs=()
  for font in "${@}"; do
    if [ ! -z "$font" ]; then
      # Ensure that directory exists, and offer suggestions if not
      if [[ ! -d "$nerdfonts_root_dir/$font" ]]; then
        echo -e "Font $font doesn't exist. Options are: \n"
        find "$nerdfonts_root_dir" -maxdepth 1 -type d \( \! -name "$(basename "$nerdfonts_root_dir")" \) -exec basename {} \;
        exit -1
      fi
      nerdfonts_dirs=( "${nerdfonts_dirs[@]}" "$nerdfonts_root_dir/$font" )
    fi
  done
fi

# Construct directories to be searched
implode() {
    # $1 is return variable name
    # $2 is sep
    # $3... are the elements to join
    local retname=$1 sep=$2 ret=$3
    shift 3 || shift $(($#))
    printf -v "$retname" "%s" "$ret${@/#/$sep}"
}

implode find_dirs "\" \"" "${nerdfonts_dirs[@]}"
find_dirs="\"$find_dirs\""

# Put it all together into the find command we want
find_command="find $find_dirs -name '*.[o,t]tf' -type f -print0"

# Find all the font files and store in array
files=()
while IFS=  read -r -d $'\0'; do
  files+=("$REPLY")
done < <(eval "$find_command")

# copy fonts into osx font library
font_dir="/Library/Fonts/NerdFonts"
mkdir -pv "$font_dir"
for file in "${files[@]}"; do
  filename=$(basename "$file")
  sudo cp -fv "${file}" "$font_dir/$filename"
done
