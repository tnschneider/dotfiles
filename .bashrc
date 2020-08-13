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

watch() {
	ARGS="${@}"
	clear; 
	while(true); do 
	  OUTPUT=`$ARGS`
	  clear 
	  echo -e "${OUTPUT[@]}"
	  sleep 10;
	done
}

aks-login() {
	az login && az account set --subscription "firebend-mca"
}

aks-prod-east() {
	az aks get-credentials --resource-group aks-prod --name aks-k8s-prod-east
}

aks-prod-west() {
	az aks get-credentials --resource-group aks-prod --name aks-k8s-prod-west
}

aks-qa() {
	az aks get-credentials --resource-group aks-qa --name aks-k8s-qa-central
}