cd ~/project-anderson/ppmi/PPMI

for i in `ls PPMI*`
do
    if [ "`cat $i | grep Weighting | grep T1`" != "" ]
    then
	if [ "`cat $i | grep process`" = "" ]
	then
	    te="`cat $i | grep '\"TE\"' | sed s/'>$'/\!/ | sed "s/^.*>//" | sed "s/<.*$//"`"
	    #te="`echo $te | sed s/'^\(.\)\.'/'0\1\.'/`"
	    echo "$te $i"
	    #echo `cat $i | grep description | sed s/'>$'/\!/ | sed "s/^.*>//" | sed "s/<.*$//"`
	fi
    fi
done