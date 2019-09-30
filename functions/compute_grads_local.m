function [gx,gy,gz,mag]=compute_grads_local(img)
%Neighbourhood for connected components
%6 or 18 or 26
Ngh=6; 

%Pad edges to account for excessive cropping of full image
img_new=zeros(size(img)+2); 
img_new(2:end-1,2:end-1,2:end-1)=img; 
img=img_new; 

ind=find(img); 
fprintf('%d voxels in mask\n',length(ind)); 

[xx,yy,zz]=ind2sub(size(img),ind);

ind_blk=find(ones(3,3,3)); 
[blk1,blk2,blk3]=ind2sub([3,3,3],ind_blk);
d=zeros(length(ind_blk),length(ind_blk)); 
for i=1:length(ind_blk)
    d(:,i)=sqrt(sum((repmat([blk1(i),blk2(i),blk3(i)],length(ind_blk),1)-[blk1,blk2,blk3]).^2,2)); 
end
    
gx=zeros(size(img)); 
gy=zeros(size(img)); 
gz=zeros(size(img));
frst=0; 
ind_c=sub2ind([3,3,3],2,2,2); 
for i=1:length(ind)
    tmp=img(xx(i)-1:xx(i)+1,yy(i)-1:yy(i)+1,zz(i)-1:zz(i)+1); 
    if all(tmp(:))>0 
        %all voxels are populated with a volume
        %easy case
        [g1,g2,g3]=imgradientxyz(tmp); 
        gx(xx(i),yy(i),zz(i))=g1(2,2,2); 
        gy(xx(i),yy(i),zz(i))=g2(2,2,2);
        gz(xx(i),yy(i),zz(i))=g3(2,2,2);
    else
        tmp_old=tmp;
        %kernel exceeds mask
        cc=bwconncomp(~~tmp,Ngh);
        if length(cc.PixelIdxList)>1
            for j=1:length(cc.PixelIdxList) 
                if ~ismember(ind_c,cc.PixelIdxList{j})
                    %Remove values from other regions 
                    %Other regions identified as separate components
                    tmp(cc.PixelIdxList{j})=0; 
                end
            end
        end
        %Interpolate or fill 
        dtmp=d; 
        ind_zero=find(tmp==0); 
        dtmp(ind_zero,:)=inf; 
        for j=1:length(ind_zero) 
            [~,ind_min]=min(dtmp(:,ind_zero(j))); 
            tmp(ind_zero(j))=mean(tmp(ind_min)); 
        end
        
        [g1,g2,g3]=imgradientxyz(tmp); 
        gx(xx(i),yy(i),zz(i))=g1(2,2,2); 
        gy(xx(i),yy(i),zz(i))=g2(2,2,2);
        gz(xx(i),yy(i),zz(i))=g3(2,2,2);
        
    end
    show_progress(i,length(ind),frst); frst=1; 
end
mag=sqrt(gx.^2+gy.^2+gz.^2); 

%Unpad the image
mag=mag(2:end-1,2:end-1,2:end-1); 
gx=gx(2:end-1,2:end-1,2:end-1); 
gy=gy(2:end-1,2:end-1,2:end-1);
gz=gz(2:end-1,2:end-1,2:end-1);