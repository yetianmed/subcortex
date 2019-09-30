function a=imdilate_special(a)
%Test data
% clear all
% close all
% a=zeros(50,50,50);
% cnt=[20,20,20];
% for i=-10:10
%     for j=-10:10
%         for k=-10:10
%             if sqrt(i^2+j^2+k^2)<8
%                 a(cnt(1)-i,cnt(2)-j,cnt(3)-k)=rand+1; 
%             end
%         end
%     end
% end
% figure; imagesc(squeeze(a(20,:,:)),[1,2]); 

ind=find(abs(a)); 

ind_other=[1:prod(size(a))]; 
ind_other=setdiff(ind_other,ind)'; 

[x,y,z]=ind2sub(size(a),ind);
[xx,yy,zz]=ind2sub(size(a),ind_other); 

for i=1:length(ind_other) 
    tmp=sqrt(sum((repmat([xx(i),yy(i),zz(i)],length(x),1)-[x,y,z]).^2,2));
    ind_min=find(tmp==min(tmp)); 
    a(ind_other(i))=mean(a(ind(ind_min))); 
end
%figure; imagesc(squeeze(a(20,:,:)),[1,2]);
 