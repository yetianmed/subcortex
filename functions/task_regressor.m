function regressor=task_regressor(TR,T,taskfile)
% clear all
% close all
%addpath('./functions')
%If using the Custom 3 column format, prepare a plain text file (avoiding editors such as MS Word) 
%containing one line for each stimulus associated with the condition to be modelled by this EV. 
%Each line must contain three numbers: the onset time (in seconds); the duration (in seconds); 
%the relative magnitude of each stimulus (usually set to 1) 

%Convolve with HRF
Convolve=1; %0=no 1=yes


%TR=0.72; %seconds
%T=176;   %number of frames
hrf=spm_hrf(TR); 

%Fear Regressor
regressor=zeros(T,1);
%taskfile='fear.txt';
t=dlmread(taskfile);
for i=1:size(t,1)
    start=t(i,1); 
    finish=start+t(i,2);
    
    %Convert from seconds to TRs
    start=round(start/TR)+1; 
    finish=round(finish/TR)+1; 
    
    regressor(start:finish)=1;  
end
if Convolve; regressor=conv(hrf,regressor); end %Convolve with HRF
regressor=regressor(1:T);
