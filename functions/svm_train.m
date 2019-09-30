function Out=svm_train(subject_train,sFiles,reg,ind)

fprintf('\n<strong>Region %d\n',reg)
fprintf('Training SVM on (%d subjects)...\n',length(subject_train));

J=length(subject_train); %number of training subjects
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





