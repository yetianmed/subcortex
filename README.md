# Subcortex-GradientBased-Parcellation
This repository provides files including data and MATLAB code (*.m) relevant to the "Subcortex-GradientBased-Parcellation" project. 
manuscript:
Contact: Ye Tian yetianmed@gmail.com

The main script is called demo.m, which is a MTALAB code that provides data descriptions and analyses demos.

All required functions are in the folder named "functions".

Each folder corresponds to one of the main sections in this project containing relevant source data and computed metrics.

1. MapGradient

   Map the functional connectivity gradient for the human subcortex

2. fMRI-tractoraphy

   Model the connectivity gradient using fMRI-tractography

3. GeoNull

   Compute the geometry-null model

4. Group-Parcellation

   3T: Four levels of hierarchical functional parcellation for the human subcortex based on 3T resting-state fMRI data. The atlas is in MNI152 standard space with a spatial resolution of 2mm isotropic. Label for each region in a given atlas is provided in a text file. 

   7T: Four levels of hierarchical functional parcellation for the human subcortex based on 3T resting-state fMRI data. The atlas is in MNI152 standard space with a spatial resolution of 1.6mm isotropic.

5. Homogeneity

   Estimate the functional homogeneity of delineated atlas.

6. Individual-Parcellation

   Train a support-vector machine (SVM) classifier and apply the classifier to predict individual parcellation.

7. Behavior

   Decompose high dimensional behavioral data into 5 dimensions using independent component analysis (ICA). The resulted independent components are provided in MATLAB format (.mat) and spreadsheet(.xlsx).







 

 
