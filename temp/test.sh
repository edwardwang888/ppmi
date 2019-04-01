for i in `ls`; do ln -s $(find "/u/project/anderson/edwardwa/ppmi/PPMI/$(echo $i | sed s/'__'/'\/'/g)" -mindepth 1 -maxdepth 1 | grep nii) ../PPMI_ep2d/scans/${i}.nii; done

for i in `find -mindepth 5 -maxdepth 5 | grep nii | sed s/'..'//`; do ln -s `pwd`/$i ../scans/$(echo $i | sed s/'\/[^\/]*$'/'.nii.gz'/ | sed s/'\/'/'__'/g); done

for i in `find -mindepth 5 -maxdepth 5 | grep nii | sed s/'..'//`; do ln -s "/u/project/anderson/edwardwa/ppmi/PPMI_ep2d/PPMI/${i}" ../scans/$(echo $i | sed s/'\/[^\/]*'// | sed s/'\/'/'__'/g); done