#!/bin/bash

ERR_ARGS=-1

if [ $# -ne 4 ]; then
  echo "Usage: `basename $0` nom_VM nom_APP type_APP param_APP"
  exit $ERR_ARGS
fi

echo -e "\n\e[1;44m   Vérification des paramètres   \e[0m";
case $3 in
    client)
	;;
    normal)
	;;
    serveur)	
	;;	
    *)
	echo "type_APP: client | serveur | normal : $3"
	exit $ERR_ARGS;;
esac

mkdir -p logs/$1/
LOG="logs/$1/appSetup.log"

# On récupère l'adresse du controller
ADR=`rake roles:show | grep 'controller' | grep -o -E '[^: ]*\.grid5000\.fr'`;

# On se connecte au controleur pour récupérer l'IP de la VM
IP=`ssh root@$ADR "source openstack-openrc.sh && nova list --name $1" | cut -d '|' -f 7 | grep -o -E '(10\.([0-9]{1,3}\.){2}[0-9]{1,3})'`;

echo -e "\n\e[1;44m   Copie de l'application ($2) sur la VM   \e[0m"
scp -q -p -r ../apps/$2 debian@$IP: >> $LOG

echo -e "\n\e[1;44m   Démarrage de l'application   \e[0m"
ssh -q debian@$IP "cd $2; make $3; ls -l; ./$3 $4" >> $LOG &
echo -e "\e[1;42m   Application démarrée   \e[0m"

exit 0
