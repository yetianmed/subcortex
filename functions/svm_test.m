function [y_img,dice]=svm_test(img_dil,Out,s_test,ind)

% INPUT
% img_dil:3-D image (matrix) comprises region of interest and its uncertainty zone
% Out: classifier computed from svm_train.m
% s_test: similarity matrix of new subject in testing samples
% ind: index of all subcortical voxels in the 3-D atlas image (MNI152 space)

% OUTPUT
% y_img: probabilistic map 
% dice: dice coefficient

Nxyz=size(img_dil);

Mdl=Out.Mdl;
ScoreMdl=Out.ScoreMdl;
y_gt=Out.y_gt;

ind1=find(img_dil(ind)==1); %class 1: other regions
ind2=find(img_dil(ind)==2); %class 2: region
ind_both=[ind1;ind2];
ind_out=setdiff(1:length(ind),ind_both);

s_test=s_test(ind_both,ind_out); %voxels x features x subjects
y_img=zeros(Nxyz);

y_pred=predict(Mdl,s_test);
[~,tmp]=predict(ScoreMdl,s_test);

%y_pred_score=tmp(:,2);
tmp_img=zeros(Nxyz);
tmp_img(ind(ind_both))=tmp(:,2);
y_img(:,:,:)=tmp_img;

%Dice coefficient
common=(y_pred==2 & y_gt==2);
a = sum(common(:));
b = sum(y_pred==2);
c = sum(y_gt==2);
dice=2*a/(b+c);










