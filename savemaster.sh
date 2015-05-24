#!/bin/bash -eu
################
#
# Script de sauvegarde de dossiers
#
# Created by Freebien
#
################

[ -e savemaster.cfg ] && . savemaster.cfg || ( echo "Config file doesn't exist please create it." && exit 1 )
[ -e functions.sh ] && . functions.sh || ( echo "Functions file doesn't exist." && exit 1 )

[ -d $savepath ] || mkdir -p $savepath

launch_save
