#!/bin/sh
#job.q -t 50 -d 60000 mriqc.sh
#openmp.q -t 50 -d 8000 -mt 8 mriqc.sh
#qsub -t 50 -l h_data=16G -pe shared 4 mriqc.sh

job.q -t 5 -d 2000 submit_jobs.sh