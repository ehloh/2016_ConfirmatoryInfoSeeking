function td = f_timejs( ts1raw, ts2raw)
% Take 2 javascript timestamps and calculate elapsed time 
%   Returns 2-mat: time(1)= hrs , time(2)=min 
%   Assumes that duration is < 24 hrs
   
fmat= @(mat, index)mat(index); 

% Parse into hr + min 
ts1= ts1raw(strfind(ts1raw, 'T')+1:strfind(ts1raw, '.')-1); 
ts2= ts2raw(strfind(ts2raw, 'T')+1:strfind(ts2raw, '.')-1);  
t1 = [ str2num(ts1(1:fmat(strfind(ts1, ':'),1)-1))    str2num(ts1(fmat(strfind(ts1, ':'),1)+1:fmat(strfind(ts1, ':'),1)+2))]; 
t2 = [ str2num(ts2(1:fmat(strfind(ts2, ':'),1)-1))    str2num(ts2(fmat(strfind(ts2, ':'),1)+1:fmat(strfind(ts2, ':'),1)+2))]; 
  
% Time difference 
td = t2-t1; 

% Adjust for crossover hours + minutes  
if td(2)<0;  
    td(2)=60+td(2);    
    td(1) = (t2(1)-2) -  t1(1); 
end  
if td(1)<0;  
    td(1) = 24+td(1);
end 

%% Convert to Matlab vector format 

for n=1:2
    eval(['traw =ts' num2str(n) 'raw;']) 
    tvec(1)= str2num(traw(1:4)); 
    tvec(2)= str2num(traw(6:7));
    tvec(3)= str2num(traw(9:10)); 
    traw = traw(strfind(traw,'T')+1:end); 
    tvec(4)= str2num(traw(1:2));
    tvec(5)= str2num(traw(4:5));
    tvec(6)= str2num(traw(7:8));   
    eval(['t' num2str(n) 'vec=tvec;'])
end
 
% Time elapsed in seconds 
dsecs = etime(t2vec, t1vec); 
dmin =  dsecs/60; 
dhr = dmin/60;  

% Time elapsed in hrs + min 
td(1) = floor(dhr);
td(2) = floor( dmin  - (floor(dhr)*60) );  

end

