#!/bin/sh
cd ~/project-anderson/ppmi/PPMI
top=`pwd`
for i in `echo */` #iterate through each subject
do
    cd $i
    dir0=`pwd`
    for j in `echo */` #iterate through scans
    do
	cd $j
	cd */`ls *`
	dir=`pwd`
	echo $dir
	cd ~/project-anderson/bin/dcm2niix/build/bin
	#./dcm2niix -f "PPMI-%i-%d-e%e" -o ~/project-anderson/ppmi/freesurfer_test/dcm2niix_test $dir
	cd $dir0
    done
    cd $top
done