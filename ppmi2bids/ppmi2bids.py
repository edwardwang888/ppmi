"""
Convert the PPMI database to the BIDS format.

We will iterate through each subject, creating a subject directory in the BIDS directory.
The 'anat' and 'func' subdirectories will be created. Then, we will iterate through each
scan type. The name of the scan description, as extracted from the XML metadata file, will
be the acquisition (acq-)label. Within each scan type, we will iterate through the existing
files (using the find utility to acquire a list of files) and construct arrays corresponding
to T1, T2, PD, and Flair scan types. All files containing 'flair' in the file name should be
categorized as Flair; all other files should be categorized according to the weighting as
specified in the metadata file. The arrays only need to consist of the original file paths
since the new files are named according to the BIDS naming scheme. Ensure that the files are
traversed in sorted order. After all files are processed, we will create the new files from
the array. Arrays that contain more than one element will be named with a run index.

There are three types of processed scans: T1-anatomical, T2 in T1-anatomical space, and T2 in
corrected EPI space. The processed scan type can be determined by the 'processedDataLabel'
metadata parameter. For T1-anatomical and T2 in corrected EPI space, the weighting (of the
original image) can be determined by the metadata file. T2 in T1-anatomical scans are derived
from two images, so there will be two weighting parameters in the metadatafile. They should be
labelled as 'inplaneT1' (tentatively).

EDIT: Use file names to determine processed scans, as there are inconsistencies in the metadata files.

There are two types of functional scans: ep2d_bold_rest, ep2d_RESTING_STATE. Using file names, we can
determine if a scan is functional (don't use the metadata file, as there are inconsistencies).
"""

import os, fnmatch, shutil, re, csv

#Open CSV file for writing
csvfile = open('/u/home/e/edwardwa/project-anderson/ppmi/ppmi2bids/scans.csv', 'w')
ppmiwriter = csv.writer(csvfile,quoting=csv.QUOTE_ALL)
ppmiwriter.writerow(['New Scan','Original Scan'])

def copy_files(subj, scan, runs, run_index, scan_list, modality, dest):
    for i in range(len(scan_list)):
        #origfile = re.sub('^.*\/','',scan_list[i]) #Remove full file path
        newfile = 'sub-' + subj + '_acq-' + re.sub('_','-',scan)
        if len(runs) != 1: # More than one run present
            newfile += '_run-' + '{:0>3}'.format(str(run_index+1))

        if len(scan_list) != 1:
            newfile += '_echo-' + '{:0>3}'.format(str(i+1))
        if 'ep2d' in scan:
            ending = '.nii.gz'
        else:
            ending = '.nii'
        newfile += '_' + modality + ending
        os.symlink(scan_list[i], dest + '/' + newfile)
        ppmiwriter.writerow([newfile,scan_list[i]])

def get_xml(subj, scan, filename):
    #Find corresponding XML file
    origfile=re.sub('^.*\/','',filename) #Remove full file path
    match=re.search('_[^_]*_[^_]*$',origfile)
    xml=match.group()
    xml=re.sub('.nii','.xml',xml)
    xml='PPMI_'+ subj + '_' + scan + xml
    return xml

ppmi_dir='/u/home/e/edwardwa/project-anderson/ppmi/PPMI'
bids_dir=ppmi_dir + '_BIDS'

if os.path.isdir(bids_dir):
    print("Removing directory:", bids_dir)
    shutil.rmtree(bids_dir)

print("Making directory:", bids_dir)
os.mkdir(bids_dir)

os.chdir(ppmi_dir)
for subj in os.listdir(os.getcwd()): #Iterate through each directory
    if os.path.isdir(subj):
        #Make subject directory
        subj_dir = bids_dir + '/sub-' + subj
        print("Making directory:", subj_dir)
        os.mkdir(subj_dir)
        
        #Make 'anat' directory
        anat = subj_dir + '/anat'
        print("Making directory:", anat)
        os.mkdir(anat)

        os.chdir(subj)
        for scan in os.listdir(os.getcwd()): #Iterate through each scan
            os.chdir(scan)
            runs = os.listdir(os.getcwd())
            runs.sort()
            for run_index in range(len(runs)):
                os.chdir(runs[run_index])

                #Get list of NIFTI files
                nifti=[]
                directory = os.getcwd()
                #Correct for functional scans if necessary
                if 'ep2d' in scan:
                    directory = re.sub('PPMI','PPMI_ep2d/PPMI',directory)

                for root,dirs,files in os.walk(directory):
                    for name in files:
                        nifti=nifti+[os.path.join(root,name)]
                if 'ep2d' in scan:
                    nifti=fnmatch.filter(nifti,"*.nii.gz")
                else:
                    nifti=fnmatch.filter(nifti,"*.nii")
                nifti.sort()
            
                #Check for bad scans
#                for i in nifti:
#                    #print(i)
#                    xml = get_xml(subj, scan, i)
#                    #print(xml)
#                    with open(ppmi_dir+'/'+xml) as f:
#                        catfile = f.readlines()
#                        catfile = fnmatch.filter(catfile, '*subjectIdentifier*')
#                        subj_id = catfile[0]
#                        subj_id = re.sub('^[^>]*>','',subj_id)
#                        subj_id = re.sub('<.*$\n','',subj_id)
#                        if subj_id != subj:
#                            pass
#                            print(xml)
                        

                if 'ep2d' in scan: # Functional scan present
                    #Make 'func' directory
                    func = subj_dir + '/func'
                    if not os.path.isdir(func):
                        print("Making directory:", func)
                        os.mkdir(func)
                        pass
                        
                    copy_files(subj+'_task-rest', scan, runs, run_index, nifti, 'bold', func)

                elif scan in ['T1-anatomical','T2_in_T1-anatomical_space'] or \
                        'corrected' in scan: # Processed scan present
                    if scan == 'T1-anatomical':
                        modality = 'T1w'
                    #elif scan == 'T2_in_T1-anatomical_space':
                    #    modality = 'inplaneT1'
                    else:
                        modality = 'T2w'

                    copy_files(subj, scan, runs, run_index, nifti, modality, anat)

                elif 'flair' in scan.lower():
                    copy_files(subj, scan, runs, run_index, nifti, 'FLAIR', anat)
                    pass
                
                elif 'mprage' in scan.lower() or 't1' in scan.lower():
                    copy_files(subj, scan, runs, run_index, nifti, 'T1w', anat)
                    pass

                elif 't2' in scan.lower() and not 'pd' in scan.lower():
                    copy_files(subj, scan, runs, run_index, nifti, 'T2w', anat)
                    pass

                else: # Original scan present
                    t1=[]
                    t2=[]
                    pd=[]
                    #Sort scans by type
                    for i in nifti:
                        #Find corresponding XML file
                        xml = get_xml(subj, scan, i)
                        xml_dir = '/u/home/e/edwardwa/project-anderson/ppmi/PPMI_test/PPMI'
                        with open(xml_dir+'/'+xml) as f:
                            catfile=f.readlines()
                            weighting = fnmatch.filter(catfile, '*Weighting*')
                            if len(weighting) != 0:
                                modality = weighting[len(weighting)-1]
                                modality = re.sub('^[^>]*>','',modality)
                                modality = re.sub('<.*$\n','',modality)

                                if modality == 'T1':
                                    t1.append(i)
                                elif modality == 'T2':
                                    t2.append(i)
                                else:
                                    pd.append(i)

                            else:
                                #print(xml)
                                pass
                            
                    copy_files(subj, scan, runs, run_index, t1, 'T1w', anat)
                    copy_files(subj, scan, runs, run_index, t2, 'T2w', anat)
                    copy_files(subj, scan, runs, run_index, pd, 'PD', anat)

                os.chdir('..')
            os.chdir('..')
        os.chdir('..')
csvfile.close()
