function [gx_sym,gy_sym,gz_sym,u_sym,v_sym,w_sym]=symmetrize_vector(gx,gy,gz)

% This function symmetrize gradient vectors

%Shift the image if the first dimension is odd number
if mod(size(gx,1),2)==1
    Shift=1;
    if Shift
        gx_old=gx; gy_old=gy; gz_old=gz;
        NN=size(gx);
        gx=zeros(NN(1)-1,NN(2),NN(3));
        gy=zeros(NN(1)-1,NN(2),NN(3));
        gz=zeros(NN(1)-1,NN(2),NN(3));
        gx(:,:,:)=gx_old(1:end-1,:,:);
        gy(:,:,:)=gy_old(1:end-1,:,:);
        gz(:,:,:)=gz_old(1:end-1,:,:);
    end
end
mag=sqrt(gx.^2+gy.^2+gz.^2);

gx_sym=zeros(size(gx));
gy_sym=zeros(size(gy));
gz_sym=zeros(size(gz));

N=prod(size(gx));
ind_matrix=reshape(1:N,size(gx));
ind_flip_matrix=flipud(ind_matrix);

ind=find(~~mag);
Expand=0;
for i=1:length(ind)
    
    ind_flip=find(ind(i)==ind_flip_matrix);
    if mag(ind_flip)==0
        if Expand==1
            gx_sym(ind(i))=gx(ind(i));
            gy_sym(ind(i))=gy(ind(i));
            gz_sym(ind(i))=gz(ind(i));
        else
            gx_sym(ind(i))=0; gy_sym(ind(i))=0; gz_sym(ind(i))=0;
        end
    else
        vv=[gx(ind(i)),gy(ind(i)),gz(ind(i))];
        vflip=[gx(ind_flip),gy(ind_flip),gz(ind_flip)];
        vflip(1)=-vflip(1);
        theta1=acosd(dot(vv,vflip)/(norm(vv)*norm(vflip)));
        theta2=acosd(dot(vv,-vflip)/(norm(vv)*norm(-vflip)));
        if abs(theta2)<abs(theta1)
            vflip=-vflip;
        end
        gx_sym(ind(i))=(vv(1)+vflip(1))/2;
        gy_sym(ind(i))=(vv(2)+vflip(2))/2;
        gz_sym(ind(i))=(vv(3)+vflip(3))/2;
        
    end
end

if Shift
    tmp=gx_sym; gx_sym=zeros(NN); gx_sym(1:end-1,:,:)=tmp;
    tmp=gy_sym; gy_sym=zeros(NN); gy_sym(1:end-1,:,:)=tmp;
    tmp=gz_sym; gz_sym=zeros(NN); gz_sym(1:end-1,:,:)=tmp;
end

mag_sym=sqrt(gx_sym.^2+gy_sym.^2+gz_sym.^2);
%mat2nii(mag_sym,'mag_symmetric.nii')

ind_sym=find(mag_sym);

u_sym=zeros(size(gx_sym)); % x
v_sym=zeros(size(gy_sym)); % y
w_sym=zeros(size(gz_sym)); % z

for i=1:length(ind_sym)
    [xx,yy,zz]=ind2sub(size(gx_sym),ind_sym(i));
    u_sym(ind_sym(i))=xx;
    v_sym(ind_sym(i))=yy;
    w_sym(ind_sym(i))=zz;
end








