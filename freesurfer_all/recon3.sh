#!/bin/sh

source $MODULESHOME/init/modules.sh
module use /u/project/CCN/apps/modulefiles
umask 007
module load freesurfer

recon-all -subject $1 -T2 $2 -T2pial -autorecon3 -sd $3