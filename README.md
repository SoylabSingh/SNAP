# SNAP2 (Soybean Nodule Acquisition Pipeline)

## Overview

![Comparison](input_snap_snap2.png)

This is an updated version of the companion repository of the submitted manuscript "Using Machine Learning To Develop A Fully Automated Soybean Nodule Acquisition Pipeline (SNAP)". This repository is organized in three sections as presented in the manuscript. 

Nodule detection: This section takes a root image as the input and draws bounding boxes around the detected nodules. The model was based on a RetinaNet on a ResNet50-FPN backbone.  The model was trained using ~140 diverse root samples. The AP of the model on ~30 test samples was 0.62. The base code of this model was borrowed from  https://github.com/fizyr/keras-retinanet (version 0.5.1, commit id 01737e6523c09df922d36edac332a68bcda4af90). We introduced anchor selection based on the natural size distribution of nodules. 

Tap root detection: This section takes a root image as the input and provides a binary image of the tap root. The model was based on UNet with *Resnet34 backbone with input image size 512x512 instead of 256x256*.  The model was trained on using ~40 diverse root samples. The Jaccard loss (index) on ~10 test samples was 0.5. This was based on https://github.com/karolzak/keras-unet(version 0.0.7, commit id 531f49fa8ad85ffbe1042ffa72f8c010ce329236). 

Post processing: This section takes the outputs from the nodule detection and Tap root detection models as inputs and outputs the total number of nodules per image and number of nodules close to the tap root. *The output from the the tap root model might not be accurate, it might contain parts of lateral or secondary roots and tap root might be broken into parts, this step removes those lateral parts by keeping biggest connected component and root parts near it (within 200 pixels~= *cm). Then the tap root parts are connected by the nearest endpoints between them. The nearest endpoints are identified by minimum spanning tree algorithm.* The script is written in MATALB and it performs classical image processing to generate the outputs.



# Installation 

#### Nodule and tap root detection  

1. Download the repo to local machine.

2. Download and install the latest version of anaconda. (https://www.anaconda.com/products/individual)

3. Create a new environment named "snap" using "snap.yml" (located in the downloaded repository) as: 

   $ *conda env create -f snap.yml*
   
  Once the environment has been built, use the following to activate the environment. 
  
   $ *conda activate snap*

#### Post Processing

5. Install MATLAB 2018a (or newer) with image processing toolbox. 

   

### How to use it 

To use the first two sections, open a jupyter notebook inside the snap environment and navigate to the desired section to open and exicute the .ipynb

### Nodule Detection Section

- To detect the nodules on the images in the sample_images folder run  *nodule_dector_example.ipynb* notebook in the nodule_detection folder. The detected nodules on the images and corresponding locations can be found in  sample_outputs/nodules. 

### Tap Root Detection Section

- To detect the tap root on the images in the sample_images folder run  *tap_root_detector_example.ipynb* notebook in the tap_root_detection folder. The detected tap root on the images can be found in  sample_outputs/tap_roots. 

### Post Processing Section

- To identify the number of nodules on or near the tap root run *post_processing.m* using MATLAB in the post_processing folder. The detected nodules on the tap root can be seen in nodules_on_tap_root. The total number of nodules per image and number of nodules on the tap root can be found in  *nodules_distribution_summary.csv* and *nodules_distribution.csv*  in the sample_outputs/counts folder.

- To create a csv containing all of the unique nodules of a dataset across all of the roots, run *merge_csvs_nodule_dectection.ipynb* in the post_processing folder. 

### User Assessment

-After processing images wth SNAP we recomend a visual assessment of the 'nodules' folder in the Sample_outputs directory for quality of nodule identification. This can be done by visually assessing the number of correctly identified nodules versus missed or incorrectly identified nodules to calculate precision and accuracy on a small sample of images. We also recomend to visually assess the nodules_on_tap_root folder pior to the final post processing to ensure that all of the images have quality nodule and taproot identification. 

### Citations:

If you use SNAP please cite us:

- Jubery, Talukder Z., Clayton Carley N., Soumik Sarkar, Arti Singh, Baskar Ganapathysubramanian, and Asheesh K. Singh. "Using machine learning to develop a fully automated soybean nodule acquisition pipeline (SNAP)." under review for plant phenomics.

### Funding Acknowledgements

We gratefully acknowledge funding from  the Iowa Soybean Research Center , Iowa Soybean Association, R.F. Baker Center for Plant Breeding, Plant Sciences Institute, Bayer Chair in Soybean Breeding, USDA CRIS project IOW04314, National Science Foundation Grant No. DGE-1545453 and USDA-NIFA HIPS award.

### Feel free to raise issues and contribute to the Software. 

##### Contact:  

**Baskar Ganapathysubramanian**

Mechanical Engineering Department

Iowa State University

baskarg@iastate.edu



**Asheesh Singh**

Department of Agronomy

Iowa State University

singhak@iastate.edu







