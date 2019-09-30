function img_labels=expand(msk,img_labels,Ngh,c)

ind=find(~msk); %index of voxels in subcortical mask
ind_labels=find(img_labels);
ind_missing=setdiff(ind,ind_labels);
%%%
tmp=zeros(size(img_labels));
tmp(ind)=1:length(ind);
adj=spalloc(length(ind),length(ind),10000);
for i=1:length(ind)
    [xx,yy,zz]=ind2sub(size(img_labels),ind(i));
    ngh=Ngh+repmat([xx,yy,zz],size(Ngh,1),1);
    for j=1:size(Ngh,1)
        try ind_ngh=sub2ind(size(img_labels),ngh(j,1),ngh(j,2),ngh(j,3));
            if tmp(ind_ngh)>0
                adj(i,tmp(ind_ngh))=1;
            end
        catch; end
    end
end
ind_c=[];
for j=1:size(c,1)
    ind_c=[ind_c;tmp(c(j,1),c(j,2),c(j,3))];
end
%%%
ShortestPath=1; frst=0;
for i=1:length(ind_missing)
    if ShortestPath
        d=breadth(adj,tmp(ind_missing(i))); %slow
        d(d==-1)=Inf;
        [~,ind_min]=min(d(ind_c)); ind_min=ind_min(1);
        img_labels(ind_missing(i))=img_labels(c(ind_min,1),c(ind_min,2),c(ind_min,3));
    end
    show_progress(i,length(ind_missing),frst); frst=1;
end
ind_outside=find(msk);
img_labels(ind_outside)=NaN;
img_labels=medfilt3_nan(img_labels,[3,3,3]);
img_labels(ind_outside)=0;
img_labels=img_labels.*double(~msk);