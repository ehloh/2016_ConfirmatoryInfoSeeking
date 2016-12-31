function f = f_plotorscatter(x,y,color)
% If there is more than 1 valid (non-nan) datapoint, plot; Otherwise, Scatter
  
if sum(~isnan(y))>1 && sum(~isnan(x))>1; 
    f = plot(x, y, 'color', color);   
else
    x = x( ~isnan(y) & ~isnan(x) );
    y = y( ~isnan(y) & ~isnan(x) );
    f= scatter(x,y,20,color,'filled') ;
end 
end

