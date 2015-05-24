#!/bin/bash -eu
# ----------------------------------------------------------------
# SaveMaster
# Author : Freebien
# ---------------------------------------------------------------
# These are functions for the SaveMaster Bash Script
#
# ---------------------------------------------------------------

# --- Globals variables ------------------------------------------

green="\e[32m" 
red="\e[31m" 
normal="\e[0m"

action(){
	# --- Action Function ------------------------------------
	# Launch the command in argument and will print the message
	# + and add [OK] or [FAILED]
	# ------ Arguments ---------------------------------------
	#	$1 command
	#	$2 message

	[ $# -ne 2 ] && echo "action should have 2 args $# given..." && exit 1
	# --- Processing -----------------------------------------
	if $1
	then
		printf "%*b\r%s\n" "$(( $(tput cols) + 9 ))" "[${green}OK${normal}]" "$2"
	else
		printf "%*b\r%s\n" "$(( $(tput cols) + 9 ))" "[${red}FAILED${normal}]" "$2"
	fi
}

log(){
	# --- Log ------------------------------------------------
	# Fonction permettant de logger les messages
	# + d'erreur
	# ------ Arguments ---------------------------------------
	#	-e error
	#	-i info
	#	-w warning
	#	-m message
	# --- Fonctions ------------------------------------------
	usage(){
		echo "Usage : log -[e|i|w] -m message"
		exit
	}

	# --- Options processing ---------------------------------
	[ $# -eq 0 ] && usage

	while getopts 'eiwm:' opt
	do
		case $opt in
			e)
				type="err"
				;;
			i)
				type="info"
				;;
			w)
				type="warn"
				;;
			m)
				message="$OPTARG"
				;;
			*)
				usage
				;;
		esac
	done
	
	# --- Traitement -----------------------------------------
	logger -p local7.$type -t $log_user $message
}

get_last_file_num(){
	# --- Log ------------------------------------------------
	# Récupère le fichier le plus ancien (nombre le plus grand)
	# ------ Arguments ---------------------------------------
	#	$1 : name

	# --- Variables ------------------------------------------
	local name=$1

	# --- Traitement -----------------------------------------
	for file in $savepath/$name.tar.gz.*
	do 
		echo $file | awk -F'.' '{print $NF}'
	done | sort -n | tail -n1
}

save_rotate(){
	# --- Save Rotate ----------------------------------------
	# Rotation des sauvegardes
	# ------ Arguments ---------------------------------------
	#	$1 : dossier

	# --- Variables ------------------------------------------
	local temp=$(mktemp)
	local name=$1

	# --- Traitement -----------------------------------------
	
	# ------ Log files names ---------------------------------
	for f in $(find $savepath -name "$name.tar.gz.*")
	do
		echo $f >> $temp
	done
	
	# ------ Suppress too old saves --------------------------
	if [ $(cat $temp | wc -l) -ge $max_save ]
	then
		local to_suppress=$(($(cat $temp | wc -l) - max_save + 1))
		for ((i=1; i<=$to_suppress; i++))
		do
			local n=$(get_last_file_num $name)
			action "rm $savepath/$name.tar.gz.$n" "Suppressing : $savepath/$name.tar.gz.$n"
		done
	fi

	# ------ Log files names ---------------------------------
	cat /dev/null > $temp
	for f in $(find $savepath -name "$name.tar.gz.*")
	do
		echo $f >> $temp
	done
	
	# ------ Rotating the compressed saves -------------------
	echo "Rotating files..."
	cat $temp | awk -F'.' '{print $NF}' | sort -rn | while read i
	do
		action "mv $savepath/$name.tar.gz.$i $savepath/$name.tar.gz.$((i + 1))" "$savepath/$name.tar.gz.$i to $savepath/$name.tar.gz.$((i+1))"
	done
	
	# ------ Moving the one without number -------------------
	if [ -e $savepath/$name.tar.gz ]
	then 
		action "mv $savepath/$name.tar.gz $savepath/$name.tar.gz.1" "$savepath/$name.tar.gz to $savepath/$name.tar.gz.1"
	fi
	
	# ------ Removing temporary files -------------------------
	action "rm $temp" "Suppressing temporary files..."
}


launch_save(){
	# --- Save -----------------------------------------------
	# Sauvegarde des fichiers.
	# Les différents dossiers à sauvegarder doivent se trouver 
	# + dans le fichier : folders.cfg pour pouvoir être
	# + sauvegardés

	for dir in $(cat $PWD/folders.cfg)
	do
		log -i -m "Saving - $dir"
		local name=$(basename $dir)
		save_rotate $name
		cd ${dir%/*}
		action "tar -czf ${savepath}/${name}.tar.gz $(basename $dir)" "Compressing ${savepath}/${name}..."
	done
}

