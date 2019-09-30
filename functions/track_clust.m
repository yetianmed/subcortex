function [M,dsym,VoxelSize]=track_clust(TrackFile,Lthresh,J)

% This script computes the distance between each pair of streamlines
% Input
% TrackFile: Streamlines file computed in Diffusion Toolkit
% Lthresh: length threshold of streamlines
% J:Number of points resampled for each streamline
% Output
% M: x y z coordinates for each point on each streamline
% dsym: symmetric distance matrix between pairs of streamlines
% VoxelSize: voxel size in mm

[header,tracks] = trk_read(TrackFile);
VoxelSize=header.voxel_size(1);
fprintf('Total number of streamlines %d\n',length(tracks));

lengths = trk_length(tracks);
ind_ori=find(lengths>=Lthresh);
tracks=tracks(ind_ori);
fprintf('Keep %d streamlines longer than %d mm\n',length(tracks),Lthresh);

% Number of points on each streamline
for i=1:length(tracks)
    nP(i)=tracks(i).nPoints;
end

% Resample so that each streamline comprises exactly J points
fprintf('Resampling to %d points...\n',J);
frst=0;
for i=1:length(tracks)
    x=tracks(i).matrix(:,1); y=tracks(i).matrix(:,2); z=tracks(i).matrix(:,3);
    t=[0;cumsum(sqrt(diff(x).^2+diff(y).^2+diff(z).^2))];
    t=t/t(end);
    ti=linspace(0,1,J);
    xx=spline(t,x,ti);
    yy=spline(t,y,ti);
    zz=spline(t,z,ti);
    tracks_ds(i).matrix=[xx',yy',zz'];
    tracks_ds(i).nPoints=J;
    show_progress(i,length(tracks),frst); frst=1;
end
tracks=tracks_ds; clear track_ds;

% Coordinates(x,y,z)for each point on each streamline
M=zeros(J,3,length(tracks));
for i=1:length(tracks)
    m=tracks(i).matrix;
    M(:,:,i)=m;
end

% Compute the distance across each pair of streamlines
fprintf('Computing distance matrix...\n');  % Lauren et al. 2007
d=zeros(size(M,3),size(M,3)); % distance matrix, asymmetric
frst=0;
for i=1:size(M,3)
    tmp=zeros(J,3,J);
    for k=1:J
        tmp(:,:,k)=repmat(M(k,:,i),J,1);
    end
    for j=1:size(M,3)
        dval=squeeze(sqrt(sum((repmat(M(:,:,j),1,1,J)-tmp).^2,2)));
        d(i,j)=mean(min(dval));
    end
    show_progress(i,size(M,3),frst); frst=1;
end

% Make the distance matrix symmetric
ind_upper=find(triu(ones(size(M,3),size(M,3)),1));
ind_lower=find(tril(ones(size(M,3),size(M,3)),-1));

% Take the mean of the two possible distances (i->j and j->i)
d_avg=mean([d(ind_upper),d(ind_lower)],2);
dsym=zeros(size(M,3),size(M,3));
dsym(ind_upper)=d_avg;
dsym=dsym+dsym';








