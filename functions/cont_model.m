function cont_model(savg,ind_ins_org,roiFile,Mag,Streamlines,Prefix,Vn)
% This script generates group-avearged Laplacian eigenmaps and eigenmap's
% gradient magnitude as well as vector files.

% Compute gradient for roi
[~,roi_msk]=read(roiFile);
ind_roi=find(~~roi_msk);
N=size(roi_msk);

% index of roi into the whole subcortex
ind_ind_trim=zeros(1,length(ind_roi));
for i=1:length(ind_roi)
    ind_ind_trim(i)=(find(ind_roi(i)==ind_ins_org));
end

% Similarity matrix for voxels in roi
s=savg(ind_ind_trim,ind_ind_trim);

ind_ins=ind_roi;
ins_msk=zeros(size(roi_msk));
ins_msk(ind_ins)=1;

% Compute gradients
fprintf('Computing Gradient %d\n',Vn-1);

%Compute Laplacian
Null=0; % Use gradmNull.m computing null data
img_pca=connectopic_laplacian(s,ind_ins,N,Vn,Null);

%Dilate image to avoid edge effects when computing gradients
img_pca_dilate=imdilate_special(img_pca);
img_pca_dilate(ind_ins)=img_pca(ind_ins); %restore actual roi

% Add the median filter before computing the gradient magnitude
img_pca_dilate=medfilt3(img_pca_dilate,[3 3 3]);

Subject=[Prefix,'Vn',num2str(Vn),'_'];

% This function writes out two nii images: eigenmap and
% gradient magnitude map.
compute_gradients(img_pca_dilate,ins_msk,Mag,Streamlines,Subject);



