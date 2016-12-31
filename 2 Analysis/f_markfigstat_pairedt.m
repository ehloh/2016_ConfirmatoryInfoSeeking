function [tstat pvals]= f_markstat(d, null, ycord,color)

error('NOT DONE YET')
keyboard  
tstat=nan(size(d,2),1)';
pvals=nan(size(d,2),1)';


for i=1:size(d,2)
    [tstat(i) pvals(i)]= ttest(d(:,i), ones(size(d,1),1)*null); 
    if pvals(i)<0.1 &&  pvals(i)>0.05
        hold on, scatter(i, ycord, '.', 'MarkerEdgeColor', color) 
    elseif  pvals(i)<0.05
        hold on, scatter(i, ycord, '+', 'MarkerEdgeColor', color) 
    end
end


end
