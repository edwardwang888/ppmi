#!/bin/sh

cd /u/project/anderson/edwardwa/ppmi/PPMI
output_dir="/u/project/anderson/edwardwa/ppmi/freesurfer_output"
mkdir $output_dir
rm `find $output_dir -mindepth 1 -maxdepth 1`
for i in `find $(pwd) -mindepth 5 -maxdepth 5 | grep init | sed s/init/freesurfer_output/`
do
    name=`echo $i | sed s/'^.*PPMI\/\(.*\)\/[^\/]*$'/'\1'/ | sed s/'\/'/__/g`
    source_dir=`echo ${i}/$(ls $i | grep '^[0-9]')`
    ln -s $source_dir ${output_dir}/${name}
done