#!/bin/bash -eu
################
#
# Script de sauvegarde de dossiers
#
# Created by Freebien
#
################

[ -e /opt/savemaster/savemaster.cfg ] && . /opt/savemaster/savemaster.cfg || ( echo "Config file doesn't exist please create it." && exit 1 )
[ -e /opt/savemaster/functions.sh ] && . /opt/savemaster/functions.sh || ( echo "Functions file doesn't exist." && exit 1 )

[ -d $savepath ] || mkdir -p $savepath

launch_save
