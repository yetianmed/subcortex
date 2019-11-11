## Atlas overview
### NIFTI

| File name| Magnetic strength | Scale | Number of regions | Spatial resolution|
| ----------------- | ----- | ----------------- | --------- | ------------------ |
| Tian_Subcortex_S1_3T.nii | 3T | I | 16 | 2mm isotropic |
| Tian_Subcortex_S2_3T.nii | 3T | II | 32 | 2mm isotropic |
| Tian_Subcortex_S3_3T.nii | 3T | III | 50 | 2mm isotropic |
| Tian_Subcortex_S4_3T.nii | 3T | IV | 54 | 2mm isotropic |
| Tian_Subcortex_S1_7T.nii | 7T | I | 16 | 1.6mm isotropic |
| Tian_Subcortex_S2_7T.nii | 7T | II | 34 | 1.6mm isotropic |
| Tian_Subcortex_S3_7T.nii | 7T | III | 54 | 1.6mm isotropic |
| Tian_Subcortex_S4_7T.nii | 7T | IV | 62 | 1.6mm isotropic |

**All atlases are in MNI standard space (MNI ICBM 152 nonlinear 6th generation)**

**Four hierarchical scales are provided for both 3T and 7T parcellation**

### CIFTI
**CIFTI format is provided for studies using Human Connectome Project (HCP) pipeline**

Note that the boundaries for the subcortical altas do not necessarily correspond with the boundaries of the existing subcortical structures defined as part of FreeSurfer/HCP pipeline. Any voxels outside the HCP pre-defined subcortical stucture are deleted. 

***dscalar.nii***: Subcortex atlas (3T) only

| File name | 
| ----------------- |
|Tian_Subcortex_S1_3T.dscalar.nii |
|Tian_Subcortex_S2_3T.dscalar.nii |
|Tian_Subcortex_S3_3T.dscalar.nii |
|Tian_Subcortex_S4_3T.dscalar.nii |

***dlabel.nii***: Subcortex atlas (3T) incorporated with existing cortical atlas 

| File name | 
| ----------------- |
| Gordon333.32k_fs_LR_Tian_Subcortex_S1.dlabel.nii | 
| Gordon333.32k_fs_LR_Tian_Subcortex_S2.dlabel.nii | 
| Gordon333.32k_fs_LR_Tian_Subcortex_S3.dlabel.nii | 
| Gordon333.32k_fs_LR_Tian_Subcortex_S4.dlabel.nii | 
| Q1-Q6_RelatedValidation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR_Tian_Subcortex_S1.dlabel.nii | 
| Q1-Q6_RelatedValidation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR_Tian_Subcortex_S2.dlabel.nii |  
| Q1-Q6_RelatedValidation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR_Tian_Subcortex_S3.dlabel.nii | 
| Q1-Q6_RelatedValidation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR_Tian_Subcortex_S4.dlabel.nii | 

Gordon et al 2016, Cerebral Cortex;
Glasser et al 2016, Nature
