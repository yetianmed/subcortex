![alt test](images/logo.jpg)

We are delighted to provide the neuroscience community with a new hierarchical MRI atlas of the human subcortex. 

**Atlas features:** 
- Volumetric parcellation of the human subcortex representing consensus among more than 1000 healthy adults.
- Available in four hierarchical scales as well as 3 and 7 Tesla versions. 
- Personalizable to represent individual variation in regional boundaries.
- Seamlessly integratable into well-established cortex-only parcellation atlases.

**Atlas scales:** The atlas is available in four scales, labeled Scale I-IV. Scale I is the coarsest atlas and recapitulates 8 well-known anatomical nuclei, while Scale IV is the finest and delineates 27 bilateral regions of the subcortex. Each scale is bilaterally symmetric and defines a self-contained parcellation atlas.

**Downloading the atlas:** The group-consensus atlas is provided in NIFTI and CIFTI (dlabel) format for download in the *Group-Parcellation* directory. If you are only here to download the atlas, this is the only directory that you need to visit. Both 3 and 7 Tesla versions are provided in 6th generation MNI space. This is the same space used by the Human Connectome Project.   

**How was the atlas mapped?** The guiding principle was reconciliation of two seemingly contradictory representations of brain topography: i) hard boundaries between discrete regions; and, ii) continuous gradients of spatial variation. Laplacian eigenmaps were used to represent spatial gradients in resting-state functional connectivity across the subcortical volume. An analogue of diffusion MRI tractography, called gradientography, was developed to identify and parameterize gradient magnitude peaks in these spatial gradients. Formal model selection and null hypothesis testing was then used to determine whether gradient magnitude peaks were sufficiently large to warrant boundary delineation. This process was repeated recursively for each new region delineated, until the null hypothesis of an absence of a boundary could not be rejected for any region after the fourth recursion.     

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







 

 
