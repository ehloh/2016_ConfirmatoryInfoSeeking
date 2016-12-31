function f  = f_plotribbon( dat, col, transparency)
%  Create line plot w +/- 1 SE ribbon (specify colour + transparency) 

 
% Assumed examples in rows 
mn = nanmean(dat); 
se = nanstd(dat)/sqrt(sum(~isnan(dat)));  
  
% Create polygon to plot ribbon 
x1=1:length(mn);  
% y_max =mn+se/2; 
% y_min=mn-se/2; 
y_max =mn+se;   % Ribbon is +/- 1 SE
y_min=mn-se;   
Xshape=[x1,fliplr(x1)];    
Yshape=[y_max ,fliplr(y_min)]; 

% Plot 
hold on 
f.ribbon = fill(Xshape,Yshape, min(1, col+0.3), 'EdgeColor', min(1, col+0.3));
f.mean = plot(mn, 'Color',col);
set(f.ribbon,'facealpha',transparency);
hold off

end

