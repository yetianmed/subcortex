function regressor=task_regressor(TR,T,taskfile)

%taskfile: If using the Custom 3 column format, prepare a plain text file (avoiding editors such as MS Word) 
%containing one line for each stimulus associated with the condition to be modelled by this EV. 
%Each line must contain three numbers: the onset time (in seconds); the duration (in seconds); 
%the relative magnitude of each stimulus (usually set to 1) 
% Example: 
% taskfile='fear.txt';
% 32.08   18   1
% 74.223  18   1
% 116.365  18  1

%TR: in seconds
%T: number of frames

%Convolve with HRF
Convolve=1; %0=no 1=yes

hrf=spm_hrf(TR); 

%Regressor
regressor=zeros(T,1);
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
