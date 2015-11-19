function A1_BackgroundFinderRough(catalog_in,lower,upper)

if ( ~exist('lower','var') || ~exist('upper','var') )
    lower = 1;
    upper = catalog_in.image.nPixels;
elseif ( lower > upper )
    lower = 1;
    upper = catalog_in.image.nPixels;
end

N = upper - lower + 1;

% BackgroundOnlyPixelIndices = cell(N,1);
NBackgroundOnlyPixels = nan(N,1);
BackgroundUpperLimit = (lower:upper)';

for i = 1:N
    % BackgroundOnlyPixelIndices{i,1} = find(catalog_in.image.data(:) <= BackgroundUpperLimit(i));
    % NBackgroundOnlyPixels(i,1) = size(BackgroundOnlyPixelIndices{i,1},1);
    NBackgroundOnlyPixels(i,1) = size(find(catalog_in.image.data(:) <= BackgroundUpperLimit(i)));
end

figure;
plot(BackgroundUpperLimit,NBackgroundOnlyPixels)
title('Number of pixels counted as only counting background radiation, as a function of upper count limit for that background');
xlabel('Background Upper Limit (counts)');
ylabel('Number of "background only" pixels');

end