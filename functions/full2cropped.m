function [img_new]=full2cropped(img_pca)
% Convert full size image in MNI space to cropped image
%[~,img_pca]=read(FullImage);

%Dimensions of full image
ins_msk=~~img_pca; 
    
%Bounding box
tmp=squeeze(sum(ins_msk,1)); 
[y,z]=find(tmp); 
max_y=max(y); min_y=min(y); 
max_z=max(z); min_z=min(z); 
tmp=squeeze(sum(ins_msk,2)); 
[x,z]=find(tmp); 
max_x=max(x); min_x=min(x);
Nx=max_x-min_x+1; 
Ny=max_y-min_y+1; 
Nz=max_z-min_z+1; 

img_new=img_pca(min_x:max_x,min_y:max_y,min_z:max_z);
% Can use mat2nii.m to write out a nii image