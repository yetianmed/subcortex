function [exp_avg,exp_avg_null,z]=do_homogeneity(dataFile1,dataFile2,mskFile,parcelFile,gmFile,MM,FWHM,voxelsize)

% Output:
% exp_avg: mean homogeneity for the empirical parcellation 
% exp_avg_null: mean homogeneity for random parcellations
% z: internal connectivity matrix between each pair of parcels

warning off

% gray matter mask
[~,gm_msk]=read(gmFile); ind_msk=find(gm_msk);

% Process images
% L-R phase encoding
system(['gunzip ',dataFile1]);
dataFile1=dataFile1(1:end-3);

fprintf('Reading and smooth data with FWHM=%dmm\n',FWHM);
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

% Perform Wishart filter, Glasser et al 2016
fprintf('Wishart filtering\n')
DEMDT=1; %Use 1 if demeaning and detrending (e.g. a timeseries) or -1 if not doing this (e.g. a PCA series)
VN=1; %Initial variance normalization dimensionality
Iterate=2; %Iterate to convergence of dim estimate and variance normalization
NDist=2; %Number of Wishart Filters to apply (for most single subject CIFTI grayordinates data 2 works well)

Out=icaDim(xLR',DEMDT,VN,Iterate,NDist);
xLR=Out.data';

% %Demean and std
xLR=detrend(xLR,'constant'); xLR=xLR./repmat(std(xLR),T,1); %remove mean and make std=1

clear i j Out

% R-L phase encoding
system(['gunzip ',dataFile2]);
dataFile2=dataFile2(1:end-3);
fprintf('Reading and Smooth Data with FWHM=%dmm\n',FWHM)
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

% Demean and std
xRL=detrend(xRL,'constant'); xRL=xRL./repmat(std(xRL),T,1); %remove mean and make std=1

clear i j Out

% Concatenate the two runs
x=[xLR;xRL];
T=size(xLR,1) + size(xRL,1);

% Demean again.
x=detrend(x,'constant'); x=x./repmat(std(x),T,1); %remove mean and make std=1

fprintf('Computing homogeneity for empirical data\n')
[~,sub_msk]=read(mskFile);

expl=zeros(1,max(sub_msk(:)));
x_roi_mean=zeros(T,max(sub_msk(:)));

for i=1:max(sub_msk(:)) % Loop over every parcel in the atlas
    
    ind_roi=find(sub_msk==i);
    
    % index of subcortical voxels into the whole gray matter mask
    ind_ind_roi=zeros(1,length(ind_roi));
    for ii=1:length(ind_roi)
        ind_ind_roi(ii)=find(ind_roi(ii)==ind_msk);
    end
    x_roi=x(:,ind_ind_roi); % x has already been demeaned
    
    % PCA on time series
    [~, ~, ~, ~, explained] = pca(x_roi,'Rows','complete');
    expl(i)=explained(1); % Variance explained by the 1st PC
    
    % internal matrix
    x_roi_mean(:,i)=mean(x_roi,2);
end

% Average across all parcels
exp_avg=mean(expl);
fprintf('Mean homogeneity=%0.2f\n',exp_avg)

clear expl

% internal connectivity matrix (optional)
x_roi_mean=detrend(x_roi_mean,'constant'); x_roi_mean=x_roi_mean./repmat(std(x_roi_mean),T,1);
c=corr(x_roi_mean);
z=atanh(c); clear c

% Randomization
fprintf('Loading precomputed random parcellations\n')
load(parcelFile,'parcels_random_all')
exp_avg_null=zeros(MM,1);

for m=1:MM
    
    parcels_random=parcels_random_all(:,:,:,m);
    
    expl=zeros(1,max(parcels_random(:)));
    
    for i=1:max(parcels_random(:))
        ind_roi=find(parcels_random==i);
        
        % index of subcortical voxels into whole gray matter mask
        ind_ind_roi=zeros(1,length(ind_roi));
        for ii=1:length(ind_roi)
            ind_ind_roi(ii)=find(ind_roi(ii)==ind_msk);
        end
        
        x_roi=x(:,ind_ind_roi); % x has already been demeaned
        
        % PCA on time series
        [~, ~, ~, ~, explained] = pca(x_roi,'Rows','complete');
        if ~isempty(explained)
            expl(i)=explained(1);
        else
            fprintf('Warning: region %d empty\n',i)
        end
    end
    
    exp_avg_null(m)=mean(expl);
    fprintf('randomisation %d of %d,mean homogeneity=%0.2f\n',m,MM,mean(expl))
    clear expl
end





