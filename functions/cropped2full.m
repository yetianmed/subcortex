function img_new=cropped2full(CroppedImage,FullImage)
%Convert cropped image to full size image in MNI space

%Read in cropped image. This image will be converted to full size
[~,img_crop]=read(CroppedImage);

%Read in original full size mask. 
[~,img_full]=read(FullImage);

%Dimensions of full image
N=size(img_full);

ins_msk=~~img_full;

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

%This is what was done to crop the image
img_new=zeros(N);
img_new(min_x:max_x,min_y:max_y,min_z:max_z)=img_crop;

