function parcels_random_all=random_parcels(mskfile,MM)

[~,parcels]=read(mskfile);

parcels_random=zeros(size(parcels));
parcels_random_all=zeros([size(parcels),MM]);

for m=1:MM
    
    ind=find(parcels);
    
    J=length(ind); %total number of voxels in subcortex
    
    M=length(unique(parcels))-1; %number of subregions;
    
    [x,y,z]=ind2sub(size(parcels),ind);
    
    %Determine center of each random region
    c=zeros(M,1);
    c(1)=ceil(rand*J);
    for i=2:M
        for j=1:i-1
            d(j,:)=sqrt((x(c(j))-x).^2+(y(c(j))-y).^2+(z(c(j))-z).^2);
        end
        if size(d,1)==1
            [~,ind_new]=max(d);
        else
            [~,ind_new]=max(min(d));
        end
        c(i)=ind_new(1);
    end
    
    for i=1:J
        d=sqrt((x(i)-x(c)).^2+(y(i)-y(c)).^2+(z(i)-z(c)).^2);
        [~,ind_new]=min(d);
        parcels_random(ind(i))=ind_new;
    end
    parcels_random_all(:,:,:,m)=parcels_random;
    
    clear d
    if (length(unique(parcels_random))-1)~=M
        fprintf('Warning!,number of parcels does not match\n')
    end
end
