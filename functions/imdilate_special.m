function a=imdilate_special(a)

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
 
