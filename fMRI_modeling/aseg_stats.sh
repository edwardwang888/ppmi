cd /u/home/e/edwardwa/project-anderson/ppmi/freesurfer_output
outfile="/u/home/e/edwardwa/project-anderson/ppmi/fMRI_modeling/aseg_stats.csv"
rm $outfile

for i in `ls`
do
	subj=`echo $i | sed s/"__.*$"//`
	export SUBJECTS_DIR="`pwd`/$i"
	statsfile="$i/aseg_stats.txt"
	asegstats2table --subjects $subj --tablefile $statsfile

	# Write to combined file
	header=`cat $statsfile | head -n 1`
	if [ ! -e "$outfile" ]
	then
		cat $statsfile | head -n 1 | sed s/'\t'/','/g >> $outfile # Write header
	fi
	cat $statsfile | tail -n 1 | sed s/'^[0-9]*'/"$i"/ | sed s/'\t'/','/g >> $outfile
done
