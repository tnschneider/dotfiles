repo() {
	cd "$HOME/Repos/$1"
}

alias c="clear"

zg() {
	filename=$(basename -- "$1")

	zip "$filename" "$1"

	gpg -c "$1.zip"
}

uzg() {
	gpg "$1"

	f=$1

	zipped=${f::-4}

	unzip $zipped
}