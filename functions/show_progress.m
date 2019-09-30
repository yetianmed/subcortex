function frst=show_progress(cnt,ttl,frst);

persistent hit

%Initialise hit only when it is first declared as an empty array
if frst==0
    hit=zeros(20,1);
    fprintf('10%% 20%% 30%% 40%% 50%% 60%% 70%% 80%% 90%% 100%%\n');
end

prp=cnt/ttl;
if prp>=0.05 & hit(1)==0
    fprintf('||');
    hit(1)=1;
elseif prp>=0.1 & hit(2)==0
    fprintf('||');
    hit(2)=1;
elseif prp>=0.15 & hit(3)==0
    fprintf('||');
    hit(3)=1;    
elseif prp>=0.2 & hit(4)==0
    fprintf('||');
    hit(4)=1;
elseif prp>=0.25 & hit(5)==0
    fprintf('||');
    hit(5)=1;    
elseif prp>=0.3 & hit(6)==0
    fprintf('||');
    hit(6)=1;
elseif prp>=0.35 & hit(7)==0
    fprintf('||');
    hit(7)=1;
elseif prp>=0.4 & hit(8)==0
    fprintf('||');
    hit(8)=1;
elseif prp>=0.45 & hit(9)==0
    fprintf('||');
    hit(9)=1;    
elseif prp>=0.5 & hit(10)==0
    fprintf('||');
    hit(10)=1;
elseif prp>=0.55 & hit(11)==0
    fprintf('||');
    hit(11)=1;    
elseif prp>=0.6 & hit(12)==0
    fprintf('||');
    hit(12)=1;
elseif prp>=0.65 & hit(13)==0
    fprintf('||');
    hit(13)=1;    
elseif prp>=0.7 & hit(14)==0
    fprintf('||');
    hit(14)=1; 
elseif prp>=0.75 & hit(15)==0
    fprintf('||');
    hit(15)=1; 
elseif prp>=0.8 & hit(16)==0
    fprintf('||');
    hit(16)=1;
elseif prp>=0.85 & hit(17)==0
    fprintf('||');
    hit(17)=1;
elseif prp>=0.9 & hit(18)==0
    fprintf('||');
    hit(18)=1;
elseif prp>=0.95 & hit(19)==0
    fprintf('||');
    hit(19)=1;   
elseif prp>=0.99 & hit(20)==0
    fprintf('||\n');
    hit(20)=1;
end    

frst=1; 