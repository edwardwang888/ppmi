#!/bin/sh
source $MODULESHOME/init/sh
module load matlab/9.1_MCR

#cd ~/project-anderson/ppmi/PPMI/
cd /u/home/e/edwardwa/project-anderson/ppmi/PPMI_ep2d/PPMI


#Remove old files
#for i in `find -mindepth 5 -maxdepth 5 | grep -v '\.dcm'`
#do
#    rm -v $i
#done


list=`find $(pwd) -mindepth 4 -maxdepth 4`
#cd ~/project-anderson/bin/dcm2niix/build/bin
export PATH=$PATH:~/.local/bin
index=0
for i in $list
do
    #if [ "`ls $i | grep .dcm`" != "" ] # only run if dicom files present
    if [ "`ls $i | grep nii`" == "" ]
    then
	echo;echo;echo "-------------------------------------------------------------------";
	echo "Examining directory: $i"
	#dcm2niix -f "PPMI-converted-%i-%d-e%e" $i
	dicm2nii $i $i
	if [ "$?" -ne "0" ]
	then
	    failed[$index]="$i"
	    index=`expr $index + 1`
	fi
    #else
	#echo "No DICOM files found in this directory!"
    fi
done

echo;echo
if [ $index -ne 0 ]
then
    echo "-------------------------------------------------------------------"
    echo "Unsuccesful conversions:"
    for i in ${failed[@]}
    do
	echo $i
    done
fi