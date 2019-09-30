function [img_pca,img_pca_null]=connectopic_laplacian(s,ind_ins,N,Vn,Null,NumNull)
% Input:
% s: similarity matrx
% ind_ins: index of subcortical voxels
% N: size of image (91x109x91)
% K: degree, used when Disparity=1
% Vn: index of gradient to compute: Vn=2 -> Gradint I; Vn=3 -> Gradient II; Vn=4 -> Gradient III
% Null: 0->No 1-> Yes
% NumNull: Number of randomizations
% Output:
% img_pca: eigenmap (main output)
% img_pca_null: eigenmap computed from null data

%Global thresholding. Haak et al 2017
img_pca=zeros(N);
w=squareform(pdist(s));  %similarity to distance mapping

fprintf('Thresholding to minimum density needed for graph to remain connected\n');
ind_upper=find(triu(ones(length(w),length(w)),1));
[~,ind_srt]=sort(w(ind_upper));
w_thresh=zeros(length(w),length(w));
dns=linspace(0.001,1,1000);
for i=1:length(dns)
    ttl=ceil(length(ind_upper)*dns(i));
    w_thresh(ind_upper(ind_srt(1:ttl)))=s(ind_upper(ind_srt(1:ttl)));
    [~,comp_sizes]=get_components(~~w_thresh+~~w_thresh');
    if length(comp_sizes)==1
        break
    end
end

fprintf('Density=%0.2f%%\n',100*(length(find(~~w_thresh))/length(ind_upper)));
dns=dns(i);
w_thresh=w_thresh+w_thresh';

fprintf('Computing Laplacian\n');
L=diag(sum(w_thresh))-w_thresh;

fprintf('Finding eigenvectors\n');
[v,d]=eig(L);d=diag(d);

% Variance explained
per=1./d(2:end);
per=per/sum(per)*100;

if v(1,Vn)>v(end,Vn)
    y=v(:,Vn);
else
    y=-v(:,Vn);
end
min_val=min(y);
y=y-min_val;
img_pca(ind_ins)=y;

if Null==1
    fprintf('Null Model: Synthetic data + MST + Geometry\n');
    
    % Reference matrix
    fprintf('Generating reference matrix\n')
    M=zeros(length(ind_ins),length(ind_ins));
    for i=1:length(ind_ins)
        for j=1:length(ind_ins)
            [xx1,yy1,zz1]=ind2sub(N,ind_ins(i));
            [xx2,yy2,zz2]=ind2sub(N,ind_ins(j));
            dd=sqrt((xx1-xx2)^2 + (yy1-yy2)^2 + (zz1-zz2)^2);
            if dd<=sqrt(2)
                M(i,j)=1;
            end
        end
    end
    ind_m_upper=find(triu(M,1)); % All the available locations (neighboring only)
    
    % Randomizations
    img_pca_null=zeros([N,NumNull]);
    for nn=1:NumNull
        fprintf('Simulating random data %d\n',nn)
        x=randn([N,2400]);
        T=size(x,4);
        FWHM=6; voxelsize=2;
        x_ins=zeros(T,length(ind_ins));
        frst=0;
        for i=1:T
            x(:,:,:,i)=imgaussfilt3(x(:,:,:,i),FWHM/voxelsize/2.355);
            tmp=x(:,:,:,i);
            x_ins(i,:)=tmp(ind_ins);
            show_progress(i,T,frst);frst=1;
        end
        clear x
        % Normalization
        x_ins=detrend(x_ins,'constant'); x_ins=x_ins./repmat(std(x_ins),T,1);
        
        % Correlation
        c=x_ins'*x_ins; c=c/T;z=atanh(c);
        
        [~,ind_srt_z]=sort(z(ind_upper),'descend');
        ind_z_upper=ind_upper(ind_srt_z(1:ttl)); % Available locations;ttl is computed from acutual data
        
        % MST ensures that the graph is fully connected
        % Only allow MST found in the neighboring locations
        ss=zeros(size(s));
        ss(ind_m_upper)=rand(length(ind_m_upper),1);
        ss=ss+ss';
        
        mst=adjacency(minspantree(graph(ss)));
        ind_mst_upper=find(triu(mst,1));
        
        % Randomise top weighted edges.
        ind_srt_ttl=ind_upper(ind_srt(1:ttl));
        ind_rand=randperm(length(ind_srt_ttl));
        ind_srt_ttl=ind_srt_ttl(ind_rand);
        
        % Add edges to mst locations first
        Nm=length(ind_mst_upper);
        w_thresh_null=zeros(size(s));
        w_thresh_null(ind_mst_upper)=s(ind_srt_ttl(1:Nm));
        
        % Then, add remaining edges to remaining desired locations
        ind_remain=setdiff(ind_z_upper,ind_mst_upper);
        ind_rand=randperm(length(ind_remain));
        ind_remain=ind_remain(ind_rand);
        w_thresh_null(ind_remain(1:ttl-Nm))=s(ind_srt_ttl(Nm+1:ttl));
        
        [~,comp_sizes]=get_components(~~w_thresh_null+~~w_thresh_null');
        if length(comp_sizes)~=1
            fprintf('Warning: Null model is not fully connected\n')
        end
        dns_null=length(find(~~w_thresh_null))/length(ind_upper);
        fprintf('Density null=%0.2f%%\n',dns_null*100);
        
        w_thresh_null=w_thresh_null + w_thresh_null';
        
        fprintf('Computing Laplacian\n');
        L=diag(sum(w_thresh_null))-w_thresh_null;
        
        fprintf('Finding eigenvectors\n');
        [v,d]=eig(L);d=diag(d);
        
        if v(1,Vn)>v(end,Vn)
            y=v(:,Vn);
        else
            y=-v(:,Vn);
        end
        min_val_null=min(y);
        y=y-min_val_null;
        tmp=zeros(N);
        tmp(ind_ins)=y;
        img_pca_null(:,:,:,nn)=tmp;
        
    end
else
    img_pca_null=[];
end
