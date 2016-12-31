function [ xnorm, mu, sigma] = f_featurenorm(x)
% Feature normalize using gaussian 

mu = nanmean(x);
xnorm = bsxfun(@minus, x, mu); 
xnorm = bsxfun(@rdivide, x, nanstd(xnorm)); 

 end

