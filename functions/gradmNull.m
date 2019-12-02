function [img_mag_null,img_pca_null]=gradmNull(savg,roiFile,Null)
% This script generates null data for gradient magnitude

% INPUT
% savg: similarity matrix
% NumNull: Number of randomizations
% roiFile: region to test

% OUTPUT
% img_mag_null: null data of gradient magnitude 
% img_pca_null: null data of eigenmap

% subcortex mask
insFile='subcortex_mask.nii';
[~,ins_msk]=read(insFile); ind_ins_org=find(ins_msk);
N=size(ins_msk);

Vn=2; % Gradient I

[~,trim_msk]=read(roiFile);
ind_trim=find(~~trim_msk);

% index of roi into ind_ins_org
ind_ind_trim=zeros(1,length(ind_trim));
for i=1:length(ind_trim)
    ind_ind_trim(i)=(find(ind_trim(i)==ind_ins_org));
end

% Extract
savg=savg(ind_ind_trim,ind_ind_trim);

ind_ins=ind_trim;
ins_msk=zeros(size(trim_msk));
ins_msk(ind_ins)=1;

[~,img_pca_null]=connectopic_laplacian(savg,ind_ins,N,Vn,Null);
NumNull=Null.NumNull;

img_mag_null=zeros([N,NumNull]);

for j=1:NumNull
    img_tmp=img_pca_null(:,:,:,j);
    ind_ins=find(ins_msk);
    img_pca_null_dilate=imdilate_special(img_tmp);
    img_pca_null_dilate(ind_ins)=img_tmp(ind_ins);
    
    % Add median filter before computing the gradient magnitude
    img_pca_null_dilate=medfilt3(img_pca_null_dilate,[3 3 3]);
    
    Subject=[];
    Streamlines=0;
    Figures=0;
    [Gx,Gy,Gz]=compute_gradients(img_pca_null_dilate,ins_msk,Subject,Figures,Streamlines);
    
    mag_null=sqrt(Gx(ind_ins).^2+Gy(ind_ins).^2+Gz(ind_ins).^2);
    tmp=zeros(N);
    tmp(ind_ins)=mag_null;
    img_mag_null(:,:,:,j)=tmp;
    
    fprintf('Region %d,finish null %d\n',Part,j)
    close all
end


