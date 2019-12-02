function s=compute_similarity (x,insFile,gmFile)
% This script computes similarity matrix between each pair of subcortcial
% voxels

% INPUT:
% x: fMRI time series, dimension time x number of all gray matter voxels
% Concatenated fMRI signals of all gray matter voxels

% insFile: binary subcortex mask in NIFTI format (*.nii)
% gmFile: binary gray matter mask in NIFTI format (*.nii)

% OUTPUT:
% s: similarity matrix (eta square)

%subcortex mask
[~,ins_msk]=read(insFile); ind_ins=find(ins_msk);

%Gray matter mask
[~,gm_msk]=read(gmFile); ind_msk=find(gm_msk);

% index of subcortex into gray matter
ind_ind_ins=zeros(1,length(ind_ins));
for i=1:length(ind_ins)
    ind_ind_ins(i)=find(ind_ins(i)==ind_msk);
end

T=size(x,1); % Number of time points

% Demean
x=detrend(x,'constant'); x=x./repmat(std(x),T,1); %remove mean and make std=1

% Subcortex time series
x_ins=x(:,ind_ind_ins);

fprintf('Computing functional connectivity for ROI...\n');

if ~any((isnan(x(:)))) % Make sure that all voxels contain no nan
    fprintf('PCA for gray matter time series...\n');
    [U,S,~]=svd(x,'econ');
    a=U*S;
    a=a(:,1:end-1);
    
    a=detrend(a,'constant');a=a./repmat(std(a),T,1); %remove mean and make std=1
    
    % Correlation
    c=x_ins'*a; c=c/T;
    zpc=atanh(c); % fisher's z transformation
    zpc=zpc(:,all(~isnan(zpc)));
    
    clear a
    
    % Compute similarity matrix
    fprintf('Computing similarity matrix\n')
    s=eta_squared(zpc); s=single(s);
    clear zpc
else
    fprintf('Error: NAN presented,check your mask\n')
    s=[];
end



