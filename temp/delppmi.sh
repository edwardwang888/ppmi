#!/bin/sh
#rm -r -v ~/project-anderson/ppmi/PPMI_old

cd /u/project/anderson/edwardwa/ppmi/PPMI
total=0
for i in `find $(pwd) -mindepth 5 -maxdepth 5 | grep freesurfer`
do
    if [ ! -d "`echo $i | sed s/freesurfer_output/init/`" ]
    then
	#total=`expr $total + $(du -h -s $i | sed s/'\(^[0-9]*\).*$'/'\1'/)`
	#echo $total
	rm -v -r $i
    fi
done