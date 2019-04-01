#!/bin/sh

#subj_index=0
#count=0
#max_per_run=8
#participants=""
#for subj in `ls /u/project/anderson/edwardwa/ppmi/PPMI_BIDS`
#do
#   if [ `expr $subj_index / $max_per_run` -ne $count ]
#   then
#       #Submit command
#       openmp.q -t 50 -d 8000 -mt 8 -m a ./mriqc.sh "$participants"
#       count=`expr $count + 1`
#       participants=""
#   fi
#   participants="${partcipants}`echo $i | sed s/sub-//` "
#   subj_index=`expr $subj_index + 1`
#done
#openmp.q -t 50 -d 8000 -mt 8 -o logs ./mriqc.sh "$participants"

#echo "Removing directory: `pwd`/mriqc_output"
#rm -r mriqc_output
#echo "Removing directory: `pwd`/work"
#rm -r work
#rm -v `find /u/home/e/edwardwa/project-anderson/ppmi/mriqc/logs`

for i in `find /u/project/anderson/edwardwa/ppmi/PPMI_BIDS -mindepth 2 -maxdepth 2 | grep func`
do
    subj="`echo $i | sed s/'^[^-]*-\([^\/]*\)\/.*$'/'\1'/`"
    if [ "`cat logs/finished.txt | grep $subj`" == "" ]
    then
	echo "Subject: $subj"
	openmp.q -t 10 -d 8000 -mt 8 -o /u/home/e/edwardwa/project-anderson/ppmi/mriqc/logs -m a mriqc.sh $subj
	echo "---------------------------------";echo
    fi
done