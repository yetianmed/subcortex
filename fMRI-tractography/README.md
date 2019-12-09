Identify peaks in the gradient magnitude images using an analogue of diffusion MRI tractography called gradientography, also known as fMRI tractography. Gradientography enables parameterization of the gradient magnitude images in terms of curvilinear trajectories through the subcortical volume.
***
### File description 
See [**demo.m**](../demo.m)

### Code required
[**symmetrize_vector**](../functions/symmetrize_vector.m): Symmetrize vectors across two hemisphere if needed

[**vector2tensor.m**](../functions/vector2tensor.m): Convert vector to tensor for performing tractography in Diffusion Toolkit

[**tensor_model_2**](../functions/tensor_model_2.m): Convert vector to tensor in MRtrix format for visualization