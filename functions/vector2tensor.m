function [img,msk]=vector2tensor(gx,gy,gz)

% This function convert vector file to tensor image (Model 1) for streamline
% visulization Diffusion Toolkit using the DTI model. Only show one direction
% with respect to each of the 3 eigenvectors

N=size(gx);

%Constrained tensor model parameters
d_parallel=0.0015; %isotropic weighting 
d_perp=0.0002; %%anisotropic weighting 

tnsr1=zeros(N); %tensor image
tnsr2=zeros(N);
tnsr3=zeros(N);
tnsr4=zeros(N);
tnsr5=zeros(N);
tnsr6=zeros(N);

mag=sqrt(gx.^2+gy.^2+gz.^2);
msk=zeros(N);

ind=find(mag);
msk(ind)=1;

%all tensors have the same magnitude; only directions differ
for i=1:length(ind)
    v=[gx(ind(i));gy(ind(i));gz(ind(i))];
    v=v/mag(ind(i)); %normalize
    beta=d_perp;
    alpha=d_parallel-d_perp;
    tmp=v*v'*alpha+eye(3)*beta;
    tnsr1(ind(i))=tmp(1,1);
    tnsr2(ind(i))=tmp(1,2);
    tnsr3(ind(i))=tmp(2,2);
    tnsr4(ind(i))=tmp(1,3);
    tnsr5(ind(i))=tmp(2,3);
    tnsr6(ind(i))=tmp(3,3);
end
img=cat(4,tnsr1,tnsr2,tnsr3,tnsr4,tnsr5,tnsr6);




