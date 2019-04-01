#!/bin/sh
export PATH=$PATH:~/.local/bin
source $MODULESHOME/init/sh
module use /u/project/CCN/apps/modulefiles
umask 007
module load afni
module load ants
module load fsl
mriqc --no-sub /u/project/anderson/edwardwa/ppmi/PPMI_BIDS mriqc_output/ participant --participant-label $1