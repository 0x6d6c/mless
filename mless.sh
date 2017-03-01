#!/bin/sh
set -e

mless() {
	markdown $file | lynx -stdin
}

anyway() {
	read -p "Proceed anyway? [y/N] " yn
	case "$yn" in
		y|Y) mless ;;
		n|N) break ;;
		*)
			echo "y/Y or n/N"
			anyway ;;
	esac
}

requirements() {
	local cmd=(
		awk
		basename
		file
		lynx
		markdown
  )

	for cmd in "${cmd[@]}"; do
		if ! command -v $cmd >/dev/null 2>&1; then
			cmdnf+=($cmd)
		else
			cmdf+=($cmd)
		fi
	done

	local cmdnfcnt="${#cmdnf[@]}"
	local cmdfcnt="${#cmdf[@]}"

	if [ "$cmdnfcnt" -gt 0 ]; then
		echo "The following commands are required:"
		for cmdnf in "${cmdnf[@]}"; do
			echo " [-] $cmdnf"
		done
		if [ "$cmdfcnt" -gt 0 ]; then
			for cmdf in "${cmdf[@]}"; do
				echo " [+] $cmdf ($(which $cmdf))"
			done
		fi
		echo "Please, install the missing commands in order to continue."
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
mimetype="$(file --dereference --mime-type $file | awk {'print $2'})"

if [ "$mimetype" != "text/plain" ]; then
	echo "File '$file' is not a plain text file type ($mimetype)."
	exit 1
fi

if [ -z "$extension" ]; then
	echo "Unknow file type."
	anyway
fi

case "$extension" in
	".md"|".markdown" ) mless ;;
	*)
		echo "File '$file' is not a markdown file type."
		anyway ;;
esac
