Personalize the atlas using support-vector machine learning to account for individual variation in regional boundaries.
***
## File description
region1_probmap_001.nii: Classification probablistic map of region 1 (HIP-head-m1-rh) for example subject 001

subcortex_mask_Thresh47_symmetric_union.nii: Old subcortex mask, slightly larger than the new atlas
## Code

[**read.m**](../functions/read.m): Read NIFTI image into MATLAB

[**write.m**](../functions/write.m) and [**mat2nii.m**](../functions/mat2nii.m): Write out NIFTI image

[**svm_train.m**](../functions/svm_train.m): Train SVM model

[**svm_test.m**](../functions/svm_test.m): Test the trained classifier in new individuals

