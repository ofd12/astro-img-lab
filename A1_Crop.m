function catalog = A1_Crop(catalog_in,nPixels)
%% Crop edges off the image - nPixels pixels away from each edge
% retain original data and store cropped data in catalog.image

if (~exist('catalog_in','var') || ~isstruct(catalog_in))
    error('First argument is not specified or is not a structure array.');
end
if (~exist('nPixels','var'))
    nPixels = 130;
end

catalog = catalog_in;

iEnd = catalog.imageOriginal.dimensions(1)-nPixels;
jEnd = catalog.imageOriginal.dimensions(2)-nPixels;

% crop
catalog.image.data = catalog.imageOriginal.data(nPixels:iEnd,nPixels:jEnd);
% store new info
catalog.image.dimensions = size(catalog.image.data);
catalog.image.nPixels = catalog.image.dimensions(1).*catalog.image.dimensions(2);

end