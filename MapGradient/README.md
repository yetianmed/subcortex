Compute Laplacian eigenmaps to represent spatial gradients in resting-state functional connectivity across the subcortical volume.
***
## File description

subcortex_mask_Average_Vn2_eigenvector.nii: Group-consensus eigenmap of Gradient I

subcortex_mask_Average_Vn2_magnitude.nii: Gradient magnitude of Gradient I

Masks are in cropped space (bounding box) to aid visualization 

trackvis_txt: Colormap
## Code

[**read.m**](../functions/read.m): Read NIFTI image into MATLAB

[**write.m**](../functions/write.m) and [**mat2nii.m**](../functions/mat2nii.m): Write out NIFTI image

[**compute_similarity.m**](../functions/compute_similarity.m): Compute the similarity ([**eta_squared.m**](../functions/eta_squared.m)) in the whole-brain functional fingerprint between each pair of subcortical voxels.

[**connectopic_laplacian.m**](../functions/connectopic_laplacian.m): Compute the Laplacian eigenmaps

[**compute_gradientss.m**](../functions/compute_gradients.m): Compute the eigenmap's gradient magnitude

[**compute_grads_local.m**](../functions/compute_grads_local.m): Auxiliary function for compute_gradients.m

[**cont_model.m**](../functions/cont_model.m): This script shows how to use the above three functions




