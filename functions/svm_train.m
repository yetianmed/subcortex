function Out=svm_train(J,sFiles,img_dil,ind)

% INPUT:
% J: number of training subjects
% sFiles: a string variable with a list of name for the similarity data of
% all the training samples
% img_dil: 3-D image (matrix) comprises region of interest and its uncertainty zone
% ind: index of all subcortical voxels in the 3-D atlas image (MNI152 space)

% OUTPUT:
% Out: trained SVM model (classifier)

ind1=find(img_dil(ind)==1); %class 1: uncertainty zone
ind2=find(img_dil(ind)==2); %class 2: region
ind_both=[ind1;ind2];
ind_out=setdiff(1:length(ind),ind_both);
x=zeros(length(ind_both)*J,length(ind_out)); %voxels x features
x=single(x);

y_gt=zeros(length(ind_both),1); %classes
y_gt(1:length(ind1))=1; y_gt(length(ind1)+1:end)=2;
y=repmat(y_gt,J,1);

for j=1:J
    rng=((j-1)*length(ind_both)+1):(j*length(ind_both));
    sFile=sFiles{j};
    fprintf('Loading similarity matrix for subject %d\n',j)
    load(sFile,'s');
    s=s(ind_both,ind_out); %voxels x features
    x(rng,:)=s;
    clear s
end

fprintf('Training...\n')
Mdl=fitcsvm(x,y,'Standardize',true,'KernelFunction','RBF','KernelScale','auto','Verbose',0);
ScoreMdl=fitSVMPosterior(Mdl);

% Output
Out.Mdl=Mdl;
Out.ScoreMdl=ScoreMdl;
Out.y_gt=y_gt;

clear x y

fprintf('Finish training, save Out\n');





