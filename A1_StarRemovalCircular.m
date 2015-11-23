function catalog = A1_StarRemovalCircular(catalog_in,xCentre,yCentre,radius)
%% Remove circular area of image by specifying centre of pixel and radius of circle
% xCentre:  x coordinate of pixel at centre of circle to be removed
% yCentre:  y coordinate of pixel at centre of circle to be removed
% radius:   radius of circle to be removed
% Need to crop image first

if (~exist('catalog_in','var') || ~isstruct(catalog_in))
    error('First argument is not specified or is not a structure array.');
end

catalog = catalog_in;

% Find pixels to be removed
[xx,yy] = meshgrid(1:catalog.image.dimensions(2),1:catalog.image.dimensions(1));
retainedRegion = ((xx-xCentre).^2 + (yy-yCentre).^2)>(radius.^2);

% Removed pixels
catalog.image.data = catalog.image.data.*retainedRegion;

end