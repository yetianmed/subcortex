function [dcurve_mag_clust1_avg,dcurve_eig_clust1_avg,length_x1]=diversity_curve(M,dsym,L,VoxelSize,Avg_mag,Avg_eig,ThreshDist)

% This srcipt computes the diversity curve for each streamline 
% The are all in cropped space
% The gradient magnitude is symmetrized

% Load the group everaged eigenmap and gradient magnitude
[~,avg_mag]=read(Avg_mag); N=size(avg_mag);
[~,avg_eig]=read(Avg_eig);

% Sum of distance
s=sum(dsym,2);
[~,s_ind]=sort(s,'descend');
x1=M(:,:,s_ind); % Representative streamline with the shortest distance to all the other streamlines

% Force the coordinates start from 0 if any of them are negative
x1(x1<0)=0;
for i=1:length(x1)
    
    % Compute the length of streamline
    tmp=sqrt(sum((x1(1:end-1,:,i)-x1(2:end,:,i)).^2,2));
    length_x1(i)=sum(tmp);
    
    % Convert the coordinates from mm to voxel (Convertion used in Diffusion Toolkit and TrackVis)
    x1vol(:,:,i)=x1(:,:,i)/VoxelSize + 1; x1vol(:,:,i)=floor(x1vol(:,:,i));
end

% Exclude streamlines that go outside the mask
ind_nan=[];
for i=1:size(x1vol,3)
    tmp=squeeze(x1vol(:,:,i));
    if any(tmp(:,1)>N(1)) || any(tmp(:,2)>N(2)) || any(tmp(:,3)>N(3))
        ind_nan=[ind_nan,i];
    end
end
fprintf('%d streamlines removed\n',length(ind_nan));
x1vol(:,:,ind_nan)=[];
x1(:,:,ind_nan)=[];

% Map eigenmap and magnitude onto streamlines
dcurve_mag_clust1=zeros(L,size(x1,3));
dcurve_eig_clust1=zeros(L,size(x1,3));
for i=1:length(x1) % Loop every streamline
    for k=1:size(x1,1) % Loop every point
        dcurve_eig_clust1(k,i)=avg_eig(x1vol(k,1,i),x1vol(k,2,i),x1vol(k,3,i));
        dcurve_mag_clust1(k,i)=avg_mag(x1vol(k,1,i),x1vol(k,2,i),x1vol(k,3,i));
        if dcurve_eig_clust1(k,i)==0 && k~=size(x1,1) && k~=1
            dcurve_eig_clust1(k,i)=mean(dcurve_eig_clust1(k-1,i) + dcurve_eig_clust1(k+1,i));
            dcurve_mag_clust1(k,i)=mean(dcurve_mag_clust1(k-1,i) + dcurve_mag_clust1(k+1,i));
        end
    end
end

% Flip if necessary
for i=1:length(x1)
    c=corr(dcurve_eig_clust1(:,i),dcurve_eig_clust1(:,end));
    c_flip=corr(flipud(dcurve_eig_clust1(:,i)),dcurve_eig_clust1(:,end));
    if c_flip > c
        dcurve_eig_clust1(:,i)=flipud(dcurve_eig_clust1(:,i));
        dcurve_mag_clust1(:,i)=flipud(dcurve_mag_clust1(:,i));
        fprintf('c=%0.2f c_flip=%0.2f - Flipping\n',c,c_flip);
    else
        fprintf('c=%0.2f c_flip=%0.2f\n',c,c_flip);
    end
end

% Registration of diversity curves using dynamic time warping
% Use the reference streamline as target, no need for iteration
% Option
MaxSamp=10;
%Generate plots?
doPlots=0;

dcurve_mag_clust1_reg=zeros(size(dcurve_mag_clust1));
dcurve_eig_clust1_reg=zeros(size(dcurve_eig_clust1));
target=dcurve_mag_clust1(:,s_ind(end));
for i=1:size(dcurve_mag_clust1,2)
    [dist(i),ix,iy]=dtw(dcurve_mag_clust1(:,i),target,MaxSamp);
    dcurve_mag_clust1_reg(:,i)=interp1(1:length(ix),dcurve_mag_clust1(ix,i),linspace(1,length(ix),L));
    dcurve_eig_clust1_reg(:,i)=interp1(1:length(ix),dcurve_eig_clust1(ix,i),linspace(1,length(ix),L));
end

%ThreshDist=1; % Check the distribution of distance to decide the Threshold
ind_keep=find(dist<ThreshDist); %Index of the streamlines kept

fprintf('%d of %d streamlines kept\n',length(ind_keep),size(dcurve_mag_clust1,2));
dcurve_mag_clust1_avg=mean(dcurve_mag_clust1_reg(:,ind_keep),2);
dcurve_eig_clust1_avg=mean(dcurve_eig_clust1(:,ind_keep),2); % Just as reference for the null don't really need

if doPlots
    hf=figure; hf.Position=[100,100,1250,300];
    subplot(1,4,1);
    plot(dcurve_mag_clust1); title('Unregistered curves');
    subplot(1,4,2);
    plot(dcurve_mag_clust1_reg(:,ind_keep)); title('Registered curves');
    subplot(1,4,3);
    plot(mean(dcurve_mag_clust1,2)); title('Average across unregistered');
    subplot(1,4,4);
    plot(mean(dcurve_mag_clust1_avg,2)); title('Average across registered');
    
    hf=figure; hf.Position=[100,500,1250,300];
    subplot(1,4,1);
    plot(dcurve_eig_clust1); title('Unregistered curves');
    subplot(1,4,2);
    plot(dcurve_eig_clust1_reg(:,ind_keep)); title('Registered curves');
    subplot(1,4,3);
    plot(mean(dcurve_eig_clust1,2)); title('Average across unregistered');
    subplot(1,4,4);
    plot(mean(dcurve_eig_clust1_avg,2)); title('Average across registered');
end








