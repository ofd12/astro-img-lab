function catalog = A1_Cluster(catalog_in)
%% Find clusters

% Check thing exists
if (~exist('catalog_in','var') || ~isstruct(catalog_in))
    error('First argument is not specified or is not a structure array.');
end

catalog = catalog_in;

% Create copy of image data which will be processed and iteratively masked
imageMasked = catalog.image.data;

% Initialise values important for looping
nBrightest = 1e6;
ID = 0;
catalog.sources.desc = 'Indices in array correspond to arbitrary IDs of sources';

% Keep processing sources until nothing is left

while nBrightest > 0
    
    ID = ID + 1;
    
    % Find brightest pixel in masked source map
    [yBrightest, xBrightest] = find(imageMasked==max(imageMasked(:)));

    % Focus on single pixel if many pixels with same max
    yBrightest = yBrightest(1);
    xBrightest = xBrightest(1);
    nBrightest = imageMasked(yBrightest,xBrightest);
    
    % Circular aperture centred on pixel
    % Begin very small and take note of electron counts from pixels within aperture
    % Incrementally increase radius of aperture and keep counting
    % Once number of counts stops increasing, stop increasing aperture size
    radius = 2;
    [xx,yy] = meshgrid(1:catalog.image.dimensions(2),1:catalog.image.dimensions(1));
    aperturePhotonCountPrevious = -1;
    aperturePhotonCountCurrent = 0;
    iteration = 0;
    while ( aperturePhotonCountCurrent > aperturePhotonCountPrevious )
        aperturePhotonCountPrevious = aperturePhotonCountCurrent;
        iteration = iteration + 1;
        radius = radius + 1;
        apertureRegion = ((xx-xBrightest).^2 + (yy-yBrightest).^2) < (radius.^2);
        apertureImage = imageMasked*apertureRegion;
        aperturePhotonCountCurrent = sum(apertureImage(:));
    end

    % Find local background and subtract accordingly
    localBackground = 0;
    nSamplePixels = 1;
    
    % Store information
    catalog.sources.brightPixLocXY(ID) = [xBrightest, yBrightest];
    catalog.sources.brightPixPhotonCount(ID) = nBrightest;
    catalog.sources.regionBool(ID) = apertureRegion;
    catalog.sources.image(ID) = apertureImage;
    catalog.sources.nSourcePixels(ID) = sum(apertureRegion(:));
    catalog.sources.photonCount(ID) = aperturePhotonCountCurrent;
    catalog.sources.localBackgroundPerPixel(ID) = localBackground./nSamplePixels;
    catalog.sources.photonCountBackgroundCorrected(ID) = aperturePhotonCountCurrent - catalog.sources.localBackgroundPerPixel(ID).*catalog.sources.nSourcePixels(ID);

    % Mask region within "final" aperture and repeat process
    imageMasked = imageMasked.*~apertureRegion;

    % Give updates on progress
    fprintf('%s - processed source (ID: %g). Brightest source pixel: %g photons. All source pixels: %g photons.\n',datestr(now),ID,nBrightest,aperturePhotonCountCurrent);
    
end
    
% How many sources?
catalog.sources.nSources = length(catalog.sources.photonCount);

end