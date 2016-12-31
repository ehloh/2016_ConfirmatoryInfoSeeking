function [ h, p, t ] = f_ttest( d)
% T-test, but return a 0.5 if there is a trend  

[h, p, ci, st]= ttest(d);
t=st.tstat; 

% Mark infinite nans (usually identical samples)
h(isinf(st.tstat))= nan;

% Mark trends 
h(p<0.1 &  p >0.05)= 0.5;
  
end

