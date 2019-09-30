function img_mrtrix=tensor_model_2(gx,gy,gz)
% This script convert vector file to tensor visulization in MRtrix
% vectorFile='Average_Vn2_VectorFile.mat';

%Select eignvector
%Gradient 1, 2 or 3 
%1 is eigenvector 2, 2 is eigenvector 3, 3 is eigenvector 4 

%Scale factor for all values in the tensor
%Affects all models 
ScaleFactor=0.05; %Model 2

%Balance between isotropic and anistropic component in Model 2
%1 fully anisotropic; 0 fully isotropic
%Only affects Model 2
BalanceFactor=0.995; 

% Model 2: Outlier detection method with clipping

gx1=gx; gy1=gy; gz1=gz;

%Size of image 
N=size(gx); 

%Initialize tensors for the three models
for i=1:6
    tnsr{i}=zeros(N); %tensor image
end

mag1=sqrt(gx1.^2+gy1.^2+gz1.^2);

%Mask of non-zero eigenvectors
msk=zeros(N);
ind=find(mag1); 
msk(ind)=1; 

%Eigenvector magnitudes
mag_vec1=mag1(ind);

%Scale eignvector magnitudes
meth='quartile'; t=5;
mag_vec1x=filloutliers(mag_vec1,'clip',meth,'ThresholdFactor',t);

%V=3;
for i=1:length(ind)
    v1=[gx1(ind(i));gy1(ind(i));gz1(ind(i))];
    v1=v1/mag_vec1(i); %normalize
    
    vv=v1;
    mag_vecx=mag_vec1x;
    
    % scale anistropic component by scaled eigenvector magnitude   
    tmp2=ScaleFactor*( BalanceFactor*mag_vecx(i)*(vv*vv') + (1-BalanceFactor)*eye(3) );
    
    tnsr{1}(ind(i))=tmp2(1,1); tnsr{2}(ind(i))=tmp2(1,2);
    tnsr{3}(ind(i))=tmp2(2,2); tnsr{4}(ind(i))=tmp2(1,3);
    tnsr{5}(ind(i))=tmp2(2,3); tnsr{6}(ind(i))=tmp2(3,3);
    
end

% MRtrix order D11, D22, D33, D12, D13, D23
img_mrtrix=cat(4,tnsr{1},tnsr{3},tnsr{6},tnsr{2},tnsr{4},tnsr{5}); 



