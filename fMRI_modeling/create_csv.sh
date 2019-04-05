cd /u/home/e/edwardwa/project-anderson/ppmi/cmd_line_tool/subjects/stats_files
# Create CSV file
csv="/u/project/anderson/edwardwa/ppmi/fMRI_modeling/func_conn.csv"
# Write CSV header
path="/u/home/e/edwardwa/project-anderson/ppmi/cmd_line_tool/subjects/stats_files/85242__T1-anatomical__2015-02-18_10_24_17.0__S254440/85242__T1-anatomical__2015-02-18_10_24_17.0__S254440_global_measures_thresh_65_Power.txt"
heading=`cat $path | head -n 1 | sed s/'\" \"'/','/g | sed  s/'\"'//g`
echo "Scan,Group,Sex,Age,Weight,${heading}" | tee $csv

for i in `ls`
do
    ###################
    ## Find XML file ##
    ###################
    xml_dir="/u/home/e/edwardwa/project-anderson/ppmi/PPMI_test/PPMI"
    xml=`echo $i | sed s/'__'/'\/'/g`
    xml=`echo $xml | sed s/'__'/'\/'/g`
    xml=`echo $xml | sed s/'\/[^\/]*\(\/[^\/]*$\)'/'\1'/` # Strip date from path
    xml=`echo $xml | sed s/'\/'/'_'/g`
    xml="PPMI_$xml"
    xml=`find $xml_dir -maxdepth 1 | grep $xml`

    #############################
    ## Extract XML information ##
    #############################
    group=`cat $xml | grep "<researchGroup>" | sed -e s/'<[^>]*>'//g -e s/' '//g`
    sex=`cat $xml | grep "<subjectSex>" | sed -e s/'<[^>]*>'//g -e s/' '//g`
    age=`cat $xml | grep "<subjectAge>" | sed -e s/'<[^>]*>'//g -e s/' '//g`
    weight=`cat $xml | grep "<weightKg>" | sed -e s/'<[^>]*>'//g -e s/' '//g`

    ################
    ## Create CSV ##
    ################
    file=`find $i | grep thresh_65`
    if [ "$file" != "" ]
    then
	text=`cat $file | tail -n 1 | sed -e s/'^[^ ]* '// -e s/' '/','/g` # Functional connectivity measures
	echo "${i},${group},${sex},${age},${weight},${text}" | tee -a $csv
    fi
done