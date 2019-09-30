function img_pca=connectopic_svd(z,ind_ins,N)
%z is insula voxels by gray matter voxels
%Each row of z is the fingerprint for an insula voxel
%ind_ins is the voxel index of insula voxels
%N is 3 by 1. Dimensions of image. 

%PCA
z=detrend(z,'constant');
z(:,~any(z,1))=[]; %remove nans
[U,S,~]=svd(z,'econ');
a=U*S; 
exp=diag(S).^2; 
exp=exp/sum(exp)*100;

y=a(:,1);
min_val=min(y); 
y=y-min_val; 
img_pca=zeros(N);
img_pca(ind_ins)=y; 
%mat2nii(img_pca,'test.nii',N,32,'GMmask.nii');