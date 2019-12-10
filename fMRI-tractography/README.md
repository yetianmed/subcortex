Identify peaks in the gradient magnitude images using an analogue of diffusion MRI tractography called gradientography, also known as fMRI tractography. Gradientography enables parameterization of the gradient magnitude images in terms of curvilinear trajectories through the subcortical volume.
***
## File description 
See [**demo.m**](../demo.m)

## Code 
[**symmetrize_vector**](../functions/symmetrize_vector.m): Symmetrize vectors across two hemispheres if needed

[**vector2tensor.m**](../functions/vector2tensor.m): Convert vector to tensor for performing tractography in Diffusion Toolkit

[**tensor_model_2**](../functions/tensor_model_2.m): Convert vector to tensor in MRtrix format for visualization

[**track_clust.m**](../functions/track_clust.m): Compute distance between each pair of streamlines

[**diversity_curve.m**](../functions/diversity_curve.m): Project eigenmap and gradient magntidue onto streamlines, yielding diversity curves


