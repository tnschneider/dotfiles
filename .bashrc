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

aks() {
	env=$1
	if 	 [ $env == 'qa'   ]; then rg='aks-qa';   cluster='aks-k8s-qa-central';
	elif [ $env == 'west' ]; then rg='aks-prod'; cluster='aks-k8s-prod-west';
	elif [ $env == 'east' ]; then rg='aks-prod'; cluster='aks-k8s-prod-east';
	else echo 'invalid environment'; return 0; fi

	exec 7>&2 2>/dev/null && trap 'kill $(jobs -p) && exec 2>&7 7>&- && rm $fifoname && trap - SIGINT' SIGINT

	fifoname="/tmp/pipe_$RANDOM" && mkfifo $fifoname
	
	start "https://microsoft.com/devicelogin"

	head -n 1 $fifoname | sed -r 's/.*the code (.*) to.*/\1/' > /dev/clipboard 2>&1 & pid1=$!
	az aks get-credentials --overwrite-existing --resource-group $rg --name $cluster &> /dev/null && kubectl get po 2> $fifoname & pid2=$!

	wait $pid1 && echo "*** CODE IS COPIED TO THE CLIPBOARD ***" && wait $pid2
	
	exec 2>&7 7>&- && rm $fifoname && trap - SIGINT
}

aks-help() {
	echo "kubectl get po
kubectl delete po <pod_name>
kubectl logs <pod_name>
kubectl logs <pod_name> -f
kubectl logs <pod_name> | grep \"<search_term>\"
kubectl top pods"
}