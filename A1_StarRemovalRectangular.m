function catalog = A1_StarRemovalRectangular(catalog_in,PixelTopLeft,PixelBottomRight)
%% Remove rectangular area of image by specifying top left and bottom right pixel
% Pixels should be given as [x,y]
% Need to crop image first

if (~exist('catalog_in','var') || ~isstruct(catalog_in))
    error('First argument is not specified or is not a structure array.');
end

catalog = catalog_in;

% Removed pixels
catalog.image.data(PixelBottomRight(2):PixelTopLeft(2),PixelTopLeft(1):PixelBottomRight(1)) = 0;
end