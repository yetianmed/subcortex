function [Gx_org,Gy_org,Gz_org]=compute_gradients(img_pca,ins_msk,Subject,Figures,Streamlines)

% Compute eigenmap's gradient magnitude 

% INPUT
% img_pca is the eigenmap image in which gradients are computed
% ins_msk is a mask. Only gradients for voxels in the mask are shown in
% figure
% Subject: prefix of output
% Figures: 0->suppress figures; 1->print figures 
% slices
% Streamlines:1-> write out vector file; 0->do not write out vector file 

% OUTPUT
% Local gradient orientations for each voxel 

Erode=1; %erosion kernel
N=size(img_pca);
ind_ins=find(~~ins_msk);

% Compute gradient
% updated script to clean up edges
img_new=zeros(N);
img_new(ind_ins)=img_pca(ind_ins);
img_pca=img_new; %Remove gradients computed in boundary voxels added by dilation

[Gy,Gx,Gz,mag]=compute_grads_local(img_pca);
% %Swap order of Gx and Gy because the first output of the function is the
% %gradient along direction of increasing column subscripts.
% %With this re-ordering
% %Gx is gradient along rows    (1st dimension)
% %Gy is gradient along columns (2nd dimension)
% %Gz is gradeint in 3rd dimensions

img_mag=mag;

Gx_org=Gx; Gy_org=Gy; Gz_org=Gz;

%Crop for a better visulization
Gx=Gx.*~~ins_msk;
Gy=Gy.*~~ins_msk;
Gz=Gz.*~~ins_msk;

%Bounding box
tmp=squeeze(sum(ins_msk,1));
[y,z]=find(tmp);
max_y=max(y); min_y=min(y);
max_z=max(z); min_z=min(z);
tmp=squeeze(sum(ins_msk,2));
[x,z]=find(tmp);
max_x=max(x); min_x=min(x);
Nx=max_x-min_x+1;
Ny=max_y-min_y+1;
Nz=max_z-min_z+1;

%Write out img_pca and img_mag after cropping
if ~isempty(Subject)
    fprintf('Write out %s\n',[Subject,'magnitude.nii'])
    mat2nii(img_mag(min_x:max_x,min_y:max_y,min_z:max_z),[Subject,'magnitude.nii']);
    
    fprintf('Write out %s\n',[Subject,'eigenvector.nii'])
    mat2nii(img_pca(min_x:max_x,min_y:max_y,min_z:max_z),[Subject,'eigenvector.nii']);
end

if Streamlines
    u=repmat([1:Nx]',1,Ny); u=repmat(u,1,1,Nz);
    v=repmat([1:Ny],Nx,1); v=repmat(v,1,1,Nz);
    w=zeros(Nx,Ny,Nz);
    for i=1:Nz
        w(:,:,i)=ones(Nx,Ny)*i;
    end
    slice_msk=imerode(~~squeeze(ins_msk(min_x:max_x,min_y:max_y,min_z:max_z)),ones(Erode,Erode));
    gx=squeeze(Gx(min_x:max_x,min_y:max_y,min_z:max_z)).*slice_msk;
    gy=squeeze(Gy(min_x:max_x,min_y:max_y,min_z:max_z)).*slice_msk;
    gz=squeeze(Gz(min_x:max_x,min_y:max_y,min_z:max_z)).*slice_msk;
    
    save ([Subject,'VectorFile.mat'],'gy','gx','gz','v','u','w','Gx_org','Gy_org','Gz_org');
end

if Figures
    Mag=0; % Mag=0:print out eigenmap slices; 
           % Mag=1:print out gradient magnitude slices
    
    % Colormap consistent with Trackvis
    mycolormap=dlmread('trackvis_jet.txt');
    mycolormap(1,:)=1; % White background
     
    % Rescale according to the value in the magnitude map
    img_pca(ind_ins)=img_pca(ind_ins)/0.03*63+2;
    img_mag(ind_ins)=img_mag(ind_ins)/0.03*63+2;
    
%     %Use default colormap
%     mycolormap=parula(256); mycolormap(1,:)=1; % White background
%     img_pca(ind_ins)=img_pca(ind_ins)/max(img_pca(ind_ins))*255+2; 
%     img_mag(ind_ins)=img_mag(ind_ins)/max(img_mag(ind_ins))*255+2;
%     %Rescale to 256 colors:
%     %Bin 1->2 is white
%     %Bin 2->3 is first color
%     %Bin 256->257 is last color    

    %Sagittal
    for i=1:N(1)
        sz(i)=sum(sum(~~ins_msk(i,:,:)));
    end
    [~,ind_srt]=sort(sz,'descend'); %find slices with greatest coverage
    
    Slices=ind_srt(1:4);
    hf=figure; hf.Position=[100,300,2000,300]; hf.Color='w';
    for i=1:length(Slices)
        subplot(1,length(Slices),i)
        if Mag
            %1st dimension of image is placed on rows
            %2nd dimension of image is placed on columns
            im=image(squeeze(img_mag(Slices(i),min_y:max_y,min_z:max_z)));
        else
            im=image(squeeze(img_pca(Slices(i),min_y:max_y,min_z:max_z)));
        end
        slice_msk=imerode(~~squeeze(ins_msk(Slices(i),min_y:max_y,min_z:max_z)),ones(Erode,Erode));
        colormap(mycolormap);
        hold on;
        gx=squeeze(Gx(Slices(i),min_y:max_y,min_z:max_z)).*slice_msk;
        gy=squeeze(Gy(Slices(i),min_y:max_y,min_z:max_z)).*slice_msk;
        gz=squeeze(Gz(Slices(i),min_y:max_y,min_z:max_z)).*slice_msk;
        
        % Even the magnitude for figure
        mag=sqrt(gy.^2+gx.^2+gz.^2);
        gy=gy./mag; gx=gx./mag; gz=gz./mag;
        
        u=repmat([1:Ny]',1,Nz); v=repmat([1:Nz],Ny,1); w=ones(Ny,Nz);
        q=quiver3(v,u,w,gz,gy,gx);
        
        %First input is gradient in direction of increasing columns
        %Second input is gradient in direction of increasing rows
        q.LineWidth=0.5;
        q.Color=[192,192,192]/255;
        q.AutoScaleFactor=2;
        view(-90, 90);
        axis off;
        ax=gca; ax.XLabel.Visible='on'; ax.YLabel.Visible='on';
        axis equal;
    end
    
    % Coronal
    for i=1:N(2)
        sz(i)=sum(sum(~~ins_msk(:,i,:)));
    end
    [~,ind_srt]=sort(sz,'descend'); %find slices with greatest coverage
    Slices=ind_srt(1:4);
    hf=figure; hf.Position=[100,800,2000,300]; hf.Color='w';
    for i=1:length(Slices)
        subplot(1,length(Slices),i)
        if Mag
            %1st dimension of image is placed on rows
            %2nd dimension of image is placed on columns
            tmp=squeeze(img_mag(min_x:max_x,Slices(i),min_z:max_z));
            im=image(tmp);
        else
            tmp=squeeze(img_pca(min_x:max_x,Slices(i),min_z:max_z));
            im=image(tmp);
        end
        slice_msk=imerode(~~squeeze(ins_msk(min_x:max_x,Slices(i),min_z:max_z)),ones(Erode,Erode));
        colormap(mycolormap);
        hold on;
        gx=squeeze(Gx(min_x:max_x,Slices(i),min_z:max_z)).*slice_msk;
        gy=squeeze(Gy(min_x:max_x,Slices(i),min_z:max_z)).*slice_msk;
        gz=squeeze(Gz(min_x:max_x,Slices(i),min_z:max_z)).*slice_msk;
        
        % Even the magnitude
        mag=sqrt(gy.^2+gx.^2+gz.^2);
        gy=gy./mag; gx=gx./mag; gz=gz./mag;
        
        u=repmat([1:Nx]',1,Nz); v=repmat([1:Nz],Nx,1); w=ones(Nx,Nz);
        q=quiver3(v,u,w,gz,gx,gy);
        
        %First input is gradient in direction of increasing columns
        %Second input is gradient in direction of increasing rows
        q.LineWidth=0.5;
        q.Color=[192,192,192]/255;
        q.AutoScaleFactor=2;
        view(-90, 90);
        axis off;
        ax=gca; ax.XLabel.Visible='on'; ax.YLabel.Visible='on';
        axis equal;
    end
    
    %Axial
    for i=1:N(3)
        sz(i)=sum(sum(~~ins_msk(:,:,i)));
    end
    [~,ind_srt]=sort(sz,'descend'); %find slices with greatest coverage
    Slices=ind_srt(1:4);
    hf=figure; hf.Position=[100,1200,2000,300]; hf.Color='w';
    for i=1:length(Slices)
        subplot(1,length(Slices),i)
        if Mag
            %1st dimension of image is placed on rows
            %2nd dimension of image is placed on columns
            tmp=squeeze(img_mag(min_x:max_x,min_y:max_y,Slices(i)));
            im=image(tmp);
        else
            tmp=squeeze(img_pca(min_x:max_x,min_y:max_y,Slices(i)));
            im=image(tmp);
        end
        slice_msk=imerode(~~squeeze(ins_msk(min_x:max_x,min_y:max_y,Slices(i))),ones(Erode,Erode));
        colormap(mycolormap);
        hold on;
        gx=squeeze(Gx(min_x:max_x,min_y:max_y,Slices(i))).*slice_msk;
        gy=squeeze(Gy(min_x:max_x,min_y:max_y,Slices(i))).*slice_msk;
        gz=squeeze(Gz(min_x:max_x,min_y:max_y,Slices(i))).*slice_msk;
        
        % Even the magnitude
        mag=sqrt(gy.^2+gx.^2+gz.^2);
        gy=gy./mag; gx=gx./mag; gz=gz./mag;
        
        u=repmat([1:Nx]',1,Ny); v=repmat([1:Ny],Nx,1); w=ones(Nx,Ny);
        
        q=quiver3(v,u,w,gy,gx,gz);
        
        %First input is gradient in direction of increasing columns
        %Second input is gradient in direction of increasing rows
        q.LineWidth=0.5;
        q.Color=[192,192,192]/255;
        q.AutoScaleFactor=2;
        
        view(-90, 90);
        axis off;
        ax=gca; ax.XLabel.Visible='on'; ax.YLabel.Visible='on';
        axis equal;
    end
end


