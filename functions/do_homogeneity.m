function [exp_avg,exp_avg_null,z]=do_homogeneity(x,mskFile,parcelFile,MM)
% Input:
% x: fMRI data matrix,dimension: time x number of all gray matter voxels
% mskFile: subcortex atlas in NIFTI (*.nii)
% parcelFile: random parcellation in NIFTI (*.nii)
% MM: number of randomizations

% Output:
% exp_avg: parcellation homogeneity of the empirical parcellation 
% exp_avg_null: parcellation homogeneity of random parcellations
% z: internal connectivity matrix between each pair of parcels

warning off

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





