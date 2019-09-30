function s=compute_similarity (dataFile1,dataFile2,insFile,gmFile,FWHM,voxelsize)
% This script computes similarity matrix between each pair of subcortcial
% voxels 

%subcortex mask
[~,ins_msk]=read(insFile); ind_ins=find(ins_msk);

%Gray matter mask
[~,gm_msk]=read(gmFile); ind_msk=find(gm_msk);

% index of subcortex into gray matter
ind_ind_ins=zeros(1,length(ind_ins));
for i=1:length(ind_ins)
    ind_ind_ins(i)=find(ind_ins(i)==ind_msk);
end

% Process images
% L-R phase encoding
system(['gunzip ',dataFile1]);
dataFile1=dataFile1(1:end-3);

fprintf('Read and smooth data with FWHM=%dmm\n',FWHM);
[~,data]=read(dataFile1);
T=size(data,4);
xLR=zeros(T,length(ind_msk));
frst=0;
for i=1:T
    data(:,:,:,i)=imgaussfilt3(data(:,:,:,i),FWHM/voxelsize/2.355);
    tmp=data(:,:,:,i);
    xLR(i,:)=tmp(ind_msk);
    show_progress(i,T,frst);frst=1;
end

clear data

% Perform Wishart filter. Glasser et al. 2016
fprintf('Wishart filtering\n')
DEMDT=1; %Use 1 if demeaning and detrending (e.g. a timeseries) or -1 if not doing this (e.g. a PCA series)
VN=1; %Initial variance normalization dimensionality
Iterate=2; %Iterate to convergence of dim estimate and variance normalization
NDist=2; %Number of Wishart Filters to apply (for most single subject CIFTI grayordinates data 2 works well)

Out=icaDim(xLR',DEMDT,VN,Iterate,NDist);
xLR=Out.data';

x_insLR=xLR(:,ind_ind_ins);

% Demean and std
xLR=detrend(xLR,'constant'); xLR=xLR./repmat(std(xLR),T,1); %remove mean and make std=1
x_insLR=detrend(x_insLR,'constant'); x_insLR=x_insLR./repmat(std(x_insLR),T,1);

clear i j Out

% R-L phase encoding
system(['gunzip ',dataFile2]);
dataFile2=dataFile2(1:end-3);

fprintf('Read and smooth Data with FWHM=%dmm\n',FWHM)
[~,data]=read(dataFile2);
T=size(data,4); %number of time points
xRL=zeros(T,length(ind_msk));
frst=0;
for i=1:T
    data(:,:,:,i)=imgaussfilt3(data(:,:,:,i),FWHM/voxelsize/2.355);
    tmp=data(:,:,:,i);
    xRL(i,:)=tmp(ind_msk);
    show_progress(i,T,frst);frst=1;
end

clear data

% Perform Wishart filter
fprintf('Wishart filtering\n')
DEMDT=1; %Use 1 if demeaning and detrending (e.g. a timeseries) or -1 if not doing this (e.g. a PCA series)
VN=1; %Initial variance normalization dimensionality
Iterate=2; %Iterate to convergence of dim estimate and variance normalization
NDist=2; %Number of Wishart Filters to apply (for most single subject CIFTI grayordinates data 2 works well)

Out=icaDim(xRL',DEMDT,VN,Iterate,NDist);
xRL=Out.data';

x_insRL=xRL(:,ind_ind_ins);

% Demean and std
xRL=detrend(xRL,'constant'); xRL=xRL./repmat(std(xRL),T,1); %remove mean and make std=1
x_insRL=detrend(x_insRL,'constant'); x_insRL=x_insRL./repmat(std(x_insRL),T,1);

clear i j Out

% Concatenate the two runs
x=[xLR;xRL]; % Time series of all gray matter voxels
x_ins=[x_insLR;x_insRL]; % Time series of subcortical voxels
T=size(x_insLR,1) + size(x_insRL,1);

% Demean
x=detrend(x,'constant'); x=x./repmat(std(x),T,1); %remove mean and make std=1
x_ins=detrend(x_ins,'constant'); x_ins=x_ins./repmat(std(x_ins),T,1); %remove mean and make std=1

fprintf('Computing functional connectivity for ROI...\n');

if ~any((isnan(x(:)))) % Make sure that all voxels contain no nan
    fprintf('PCA for gray matter time series...\n');
    [U,S,~]=svd(x,'econ');
    a=U*S;
    a=a(:,1:end-1);
    
    a=detrend(a,'constant');a=a./repmat(std(a),T,1); %remove mean and make std=1
    
    % Correlation
    c=x_ins'*a; c=c/T;
    zpc=atanh(c);
    zpc=zpc(:,all(~isnan(zpc)));
    
    clear a
    
    if size(zpc,2)~=size(c,2)
        fprintf('Subject %d column deleted\n',nn);
    end
end

% Compute similarity matrix
fprintf('Computing similarity matrix\n')
s=eta_squared(zpc); s=single(s);
clear zpc

