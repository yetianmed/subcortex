![alt test](images/logo.jpg)

We are delighted to provide the neuroscience community with a new hierarchical MRI atlas of the human subcortex. 

The atlas is available in four scales, labeled Scale I-IV. Scale I is the coarsest atlas and recapitulates 8 well-known anatomical nuclei, while Scale IV is the finest and delineates 27 bilateral regions of the subcortex. Each scale is a self-contained parcellation atlas. Choose the atlas that provides adequate resolution to address your question and that matches the scale of any cortical atlas that you might be using. 

<div class="text-red mb-2"> Downloading the atlas:</div> The atlas is provided in NIFTI and CIFTI (dlabel) formats. 

**More about the atlas**

Data and code (MATLAB, *.m) related to:

Contact: Dr Ye Tian, Dr Andrew Zalesky

Email: yetianmed@gmail.com, azalesky@unimelb.edu.au

**demo.m** provides data description and analysis demo.

MATLAB code is provided in **functions**.

Each folder below corresponds to one of the main sections in the manuscript, containing relevant source data and computed metrics:

### MapGradient

   Map the functional connectivity gradients in the human subcortex.

### fMRI-tractoraphy

   Model the functional connectivity gradients using fMRI-tractography.

### GeoNull

   Model selection: Compare gradient magnitude with null data.

### Group-Parcellation

   **3T:** Group consensus hierarchical atlas of the human subcortex delineated using 3 Tesla functonal MRI data.  

   **7T:** Group consensus hierarchical atlas of the human subcortex delineated using 7 Tesla functonal MRI data.  

### Homogeneity

   Estimate the functional homogeneity of delineated atlas.

### Individual-Parcellation

   Personalize subcortical atlas using support-vector machine learning. 
   
### Behavior

   Decompose high dimensional behavioral data into 5 dimensions using independent component analysis (ICA).







 

 
