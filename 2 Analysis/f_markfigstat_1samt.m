function [tstat pvals]= f_markstat(d,ycord,color)
% Markers:  + = significant, . = trend, < = Problem (inf t stat)

tstat=nan(size(d,2),1)';
pvals=nan(size(d,2),1)';

for i=1:size(d,2)
    [t pvals(i) ci st]= ttest(d(:,i));
    tstat(i)= st.tstat;  
    
    if isinf(abs(tstat(i)))==1 % || isnan(abs(tstat(i)))==1
        hold on, scatter(i, ycord, '<', 'MarkerEdgeColor', color)  
    elseif pvals(i)<0.1 &&  pvals(i)>0.05
        hold on, scatter(i, ycord, '.', 'MarkerEdgeColor', color) 
    elseif  pvals(i)<0.05
        hold on, scatter(i, ycord, '+', 'MarkerEdgeColor', color) 
    end
end

 


end
