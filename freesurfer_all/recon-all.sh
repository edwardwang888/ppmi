#!/bin/sh

source $MODULESHOME/init/modules.sh
module use /u/project/CCN/apps/modulefiles
umask 007
module load freesurfer

recon-all -s $1 -i $2 -sd $3 -all
