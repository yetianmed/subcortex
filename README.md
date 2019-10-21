# Subcortex Parcellation Atlas (SPA)
This repository provides files including data and MATLAB code (*.m) relevant to 

*Manuscript: Functional Gradients and Parcellation of the Human Subcortex*

Contact: Ye Tian yetianmed@gmail.com

The main script is called demo.m, which is a MTALAB code that provides data descriptions and analyses demos.

All required functions are in the folder named ***functions***.

Each folder below corresponds to one of the main sections in the manuscript, containing relevant source data and computed metrics:

### MapGradient

   Map the functional connectivity gradient for the human subcortex.

### fMRI-tractoraphy

   Model the functional connectivity gradient using fMRI-tractography.

### GeoNull

   Compute the geometry-preserving null model.

### Group-Parcellation

   ***3T:*** Four levels of hierarchical functional parcellation for the human subcortex based on 3T resting-state fMRI data. The atlas is in MNI standard space with a spatial resolution of 2mm isotropic. Label for each region in a given atlas is provided in a text file. 

   ***7T:*** Four levels of hierarchical functional parcellation for the human subcortex based on 7T resting-state fMRI data. The atlas is in MNI standard space with a spatial resolution of 1.6mm isotropic.

### Homogeneity

   Estimate the functional homogeneity of delineated atlas.

### Individual-Parcellation

   Train a support-vector machine (SVM) classifier and apply the classifier to predict individual parcellation.
   
### Behavior

   Decompose high dimensional behavioral data into 5 dimensions using independent component analysis (ICA). The resulted independent components are provided in the form of a spreadsheet (individual x behavioral dimensions).







 

 
