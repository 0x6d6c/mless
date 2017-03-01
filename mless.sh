#!/bin/sh
set -e

mless() {
	markdown $file | lynx -stdin
}

requirements() {
	local cmd=(
		file
		lynx
		markdown
  )

	for cmd in "${cmd[@]}"; do
		if ! command -v $cmd >/dev/null 2>&1; then
			cmdnf+=($cmd)
		fi
	done

	local cmdnfcnt="${#cmdnf[@]}"
	if [ $cmdnfcnt -gt 0 ]; then
		echo "The following commands have not been found on your system:"
		for cmdnf in "${cmdnf[@]}"; do
			echo " [-] $cmdnf"
		done
		echo "To continue, please install missing dependencies."
		exit 1
	fi
}

requirements

file="$1"

if [ -z "$file" ]; then
	echo "Missing file."
	exit 1
	elif [ ! -f "$file" ]; then
		echo "File '$file' does not exist or it is not a regular file."
		exit 1
	elif [ ! -r "$file" ]; then
		echo "You don't have read permission to '$file'."
		exit 1
fi

filename="$(basename "$file")"
extension="$([[ "$filename" = *.* ]] && echo ".${filename##*.}" || echo '')"
mimetype="$(file --mime-type $file | awk {'print $2'})"

if [ "$mimetype" != "text/plain" ]; then
	echo "File '$file' is not a plain text file type ($mimetype)."
	exit 1
fi

if [ -z "$extension" ]; then
	echo "Unknow file type."
	exit 1
fi

case "$extension" in
	".md"|".markdown" ) mless ;;
	*) echo "File '$file' is not a markdown file type."; exit 1 ;;
esac
