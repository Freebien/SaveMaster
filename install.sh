#!/bin/bash -eu
# -----------------------------------------------------------------------
# SaveMaster Auto installer
# -----------------------------------------------------------------------
#
#

# --- Fonctions ---------------------------------------------------------
action(){
	if $1
	then
		printf "%*b\r%s\n" "$(($(tput cols) + 9))" "[${txtgreen}OK${txtnormal}]" "$2"
	else
		printf "%*b\r%s\n" "$(($(tput cols) + 9))" "[${txtred}FAILED${txtnormal}]" "$2" 1>&2
	fi	
}

# --- Variables ---------------------------------------------------------
path="/opt/savemaster"
configpath="/etc/savemaster"

txtgreen="\e[32m"
txtred="\e[31m"
txtnormal="\e[0m"
txtbold="$(tput bold)"

# --- Checks and removes ------------------------------------------------
echo "# --- Checking if savemaster is already installed... --- #"
if [ -d "$path" ]
then
	printf "$path already exists do you want to remove it ? Y/n : "
	read answer
	printf "\n"
	case $answer in
		n|N)
			echo "Keeping $path and exiting..."
			exit 0
		;;
		*)
			action "rm -Rf $path/" "Removing directory ${path}..."
			echo
		;;
	esac
fi

if [ -d "$configpath" ]
then
	printf "$configpath already exists do you want to remove it ? Y/n : "
	read answer
	printf "\n"
	case $answer in
		n|N)
			echo "Keeping $configpath and exiting..."
			exit 0
		;;
		*)
			action "rm -Rf $configpath" "Removing directory ${configpath}..."
			echo
		;;
	esac
fi

if [ -L "/usr/bin/savemaster" ]
then
	printf "/usr/bin/savemaster already exists do you want to remove it ? Y/n : "
	read answer
	printf "\n"
	case $answer in
		n|N)
			echo "Keeping /usr/bin/savemaster and exiting..."
			exit 0
		;;
		*)
			action "rm -Rf /usr/bin/savemaster" "Removing symlink savemaster..."
			echo
		;;
	esac
fi
echo "# --- Creating directories --- #"
action "mkdir $path" "Creating $path" 
action "mkdir $configpath" "Creating $configpath"

echo
echo "# --- Copying files --- #"
action "cp savemaster.sh functions.sh savemaster.cfg folders.cfg $path" "Copying files"

echo
echo "# --- Creating symlinks --- #"
action "ln -s $path/savemaster.cfg $configpath" "$configpath/savemaster.cfg"
action "ln -s $path/folders.cfg $configpath" "$configpath/folders.cfg" 
action "ln -s $path/savemaster.sh /usr/bin/savemaster" "/usr/bin/savemaster" 

echo
echo "# --- Finished --- #"
echo "Now that the installation is finished, you can configure it as you want."
echo "Configuration files are in : $configpath"
echo
echo "To start using that savemaster bash script, you have to configure the folders.cfg file"
echo "You have to write a line for each folder that needs to be saved."
