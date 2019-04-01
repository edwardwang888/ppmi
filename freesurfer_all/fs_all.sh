#!/bin/sh

#cd ~/project-anderson/ppmi/PPMI
#list=( `find  -mindepth 5 -maxdepth 5 | grep -e MPRAGE -e T1 | grep .nii | grep -v -e T2 -e anatomical | sort` )
#for i in `seq $1 $2`
#do
#    i=${list[i]}
#    sd=`echo $i | sed s/PPMI.*$//`freesurfer_output
#    sd=`pwd``echo $sd | sed s/^.//`
#    echo "Making directory: $sd"
#    mkdir $sd
#    subj=`echo $i | sed s/..// | sed s/'\/.*\/.*\/.*\/*$'//`
#    echo "Subj id: $subj"
#    file=`pwd``echo $i | sed s/^.//`
#    echo "Running recon-all on: $file"
#    job.q -t 40 -d 4000 -m a -o $sd ~/project-anderson/ppmi/freesurfer_all/recon-all.sh $subj $file $sd
#    echo -e "\n\n----------------------------------------------"
#done


#recon-all -s 10874 -i /u/project/anderson/edwardwa/ppmi/PPMI/10874/axial_spgr/2014-09-05_10_36_20.0/S235825/PPMI-converted-10874-axial_spgr-e1.nii -sd /u/project/anderson/edwardwa/ppmi/freesurfer_test1 -all



# New script to process only subjects with functional scans
cd /u/project/anderson/edwardwa/ppmi/PPMI
func_location="/u/project/anderson/edwardwa/ppmi/PPMI_ep2d/PPMI"

recon_all()
{
    local dir=`echo $1 | sed s/'\/\/'/'\/'/g`
    local subj=`echo $2 | sed s/'\/'//`
    local i=0
    for i in `find $dir -mindepth 2 -maxdepth 2 | grep nii`
    do
	#local sd="`find $dir -mindepth 1 -maxdepth 1`/freesurfer_output"  #Bad code
	local sd="`echo $i | sed s/'\(^.*\/\).*$'/'\1'/`freesurfer_output"
	
	#Only run if not run yet
	if [ ! -d $sd -o `ls $sd` = "" ]
	then
	    echo "Making directory: $sd"
	    mkdir $sd
	    echo "Subj id: $subj"
	    echo "Running recon-all on: $i"
	    job.q -t 60 -d 6000 -m a -o $sd \
		/u/project/anderson/edwardwa/ppmi/freesurfer_all/recon-all.sh $subj $i $sd
	fi
	
	#Make marker directory 'init' to mark scans that we actually will use
	marker="`echo $sd | sed s/freesurfer_output/init/`"
	echo "Making directory: $marker"
	mkdir $marker
	echo -e "\n---------------------------------------------------"
    done
}

run_freesurfer() #Pass in subject and scan name
{
    local subj="$1"
    local scan="$2"
    local i=0
    local j=0
    
    for i in `ls -d $(pwd)/${subj}/*${scan}* | grep -v T2_in_T1-anatomical_space`
    do
	for j in `ls ${func_location}/${subj}/ep2d*`
	do
	    if [ "`find $i -mindepth 1 -maxdepth 1 | grep $j`" != "" ]
	    then
		recon_all "${i}/${j}" "$subj"
		run="true"
	    fi
	done
    done
}

for subj in `cd ${func_location}; ls -d */`
do
    run="false"
    #Check if subject has T1-anatomical scan
    if [ "`ls $subj | grep T1-anatomical`" != "" ]
    then
	run_freesurfer "$subj" "T1-anatomical"
    fi

    #Run on MPRAGE scan if no T1-anatomical scan
    if [ "$run" = "false" ]
    then
	run_freesurfer "$subj" "MPRAGE"
    fi
done

