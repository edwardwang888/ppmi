cd ~/project-anderson/ppmi/PPMI
list=( `find \`pwd\` -mindepth 6 -maxdepth 6 | grep joblog | sort` )
for i in ${list[@]}
do
    if [ `cat $i | grep "recon-all.sh finished" | wc -l` = "0" ]
    then
	echo $i
    fi
done