#!/bin/sh

anat_dir="/u/project/anderson/edwardwa/ppmi/PPMI"
func_dir="${anat_dir}_ep2d/PPMI"
store_location="`pwd`/subjects"
mkdir $store_location
mkdir "${store_location}/stats_files"
#Only running for select subjects
for i in `ls /u/project/anderson/edwardwa/ppmi/freesurfer_output/ | grep -e 3122 -e 3589`
do
    subj=`echo $i | sed s/'__.*$'//`
    date=`echo $i | sed -e s/'__[^_]*$'// -e s/'^.*__'//`
    anat_file=`find ${anat_dir}/$(echo $i | sed s/__/'\/'/g) -mindepth 1 -maxdepth 1 | grep nii`
    func_file=`find ${func_dir}/${subj} -mindepth 4 -maxdepth 4 | grep ep2d | grep $date | grep nii`
    freesurfer_file=`find ${anat_dir}/$(echo $i | sed s/__/'\/'/g) -mindepth 4 -maxdepth 4 | grep aparc+aseg`
    
    #Name for ginormous move
    i="${i}_ginormous"

    sd="${store_location}/${i}"
    mkdir $sd
    
    #Run full preprocess for all scans
    job.q -t 6 -d 4000 -o $sd -m a full_preprocess.sh $i $anat_file $func_file $freesurfer_file ginormous

    #Run only functional connectivity computation
    #job.q -t 6 -d 4000 -o $sd -m a step7_preprocess.sh $i $anat_file $func_file $freesurfer_file giant
    
    #Run just for one scan
    #./full_preprocess.sh ${i} $anat_file $func_file $freesurfer_file giant
done