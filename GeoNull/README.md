Model selection: Use a geometry-preserving null model to test the null hypothesis that gradient each magnitude peak is not significantly larger in magnitude than what could be expected due to chance and/or the effects of geometry. A regional boundary is delineated at the location of gradient magnitude peaks for which the null hypothesis can be rejected. Spatial variation is represented as a continuum when the null hypothesis cannot be rejected.
***
## File description
GradmNull_subcortex_mask_part1.mat: example null data.

dcurve_avg_vn2_null_part1.mat: example diversity curves
## Code 
[**read.m**](../functions/read.m): Read NIFTI image into MATLAB

[**write.m**](../functions/write.m) and [**mat2nii.m**](../functions/mat2nii.m): Write out NIFTI image

[**gradmNull.m**](../functions/gradmNull.m): Generate the null data 
