function catalog = A1_Cluster(catalog_in,apertureRadiusLimit)
%% Find clusters, process them, store info

% Check thing exists
if (~exist('catalog_in','var') || ~isstruct(catalog_in))
    error('First argument is not specified or is not a structure array.');
end

catalog = catalog_in;

% Create copy of image data which will be processed and iteratively masked
imageMasked = catalog.analysis.sourcePixels;

% Initialise values important for looping
nBrightest = 1e6;
ID = 0;
abandonedID = 1;
backgroundRingThickness = 1;
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
    
    if nBrightest == 0
        break
    end
    
    % Circular aperture centred on pixel
    % Begin very small and take note of electron counts from pixels within aperture
    % Incrementally increase radius of aperture and keep counting
    % Once more than 99% of pixels on the outer rim are empty, desist
    %   OR desist when aperture radius = apertureRadiusLimit (user specified)
    radius = 1;
    [xx,yy] = meshgrid(1:catalog.image.dimensions(2),1:catalog.image.dimensions(1));
    % aperturePhotonCountPrevious = -1;
    aperturePhotonCountCurrent = 0;
    outerEdgeZerosFraction = 0;
    apertureNZeroPixels = 0;
    
    while ( (outerEdgeZerosFraction < 0.99) && (radius < apertureRadiusLimit) )
        % Count photons
        radius = radius + 1;
        apertureRegion = ((xx-xBrightest).^2 + (yy-yBrightest).^2) < (radius.^2);
        apertureImage = imageMasked.*apertureRegion;
        aperturePhotonCountCurrent = sum(apertureImage(:));
        % Check fraction of pixels on edge of aperture which are zero
        apertureOuterEdgeRegion = ( (((xx-xBrightest).^2 + (yy-yBrightest).^2) < ((radius).^2)) & (((xx-xBrightest).^2 + (yy-yBrightest).^2) >= ((radius-1).^2)));
        apertureOuterEdgeIndices = find(apertureOuterEdgeRegion == 1);
        apertureOuterEdgePhotonCounts = imageMasked(find(apertureOuterEdgeRegion == 1));
        apertureOuterEdgeNPixels = length(apertureOuterEdgeIndices);
        apertureOuterEdgeNZeroPixels = sum(apertureOuterEdgePhotonCounts==0);
        outerEdgeZerosFraction = apertureOuterEdgeNZeroPixels/apertureOuterEdgeNPixels;
        apertureNZeroPixels = apertureNZeroPixels + apertureOuterEdgeNZeroPixels;
    end

    % Mask region within "final" aperture and repeat process
    imageMasked = imageMasked.*~apertureRegion;
    
    % Identify annular region for local background sampling
    localBackgroundSampleRegion = ( (((xx-xBrightest).^2 + (yy-yBrightest).^2) <= ((radius+backgroundRingThickness).^2)) & (((xx-xBrightest).^2 + (yy-yBrightest).^2) >= (radius.^2)));
    % imageCropped still has the background data for reference
    localBackgroundSampleImage = catalog.imageCropped.data.*localBackgroundSampleRegion;
    % Find local background
    localBackground = sum(localBackgroundSampleImage(:));
    nSamplePixels = sum(localBackgroundSampleRegion(:));
    
    % Store information
    catalog.sources.brightPixLocX(ID) = xBrightest;
    catalog.sources.brightPixLocY(ID) = yBrightest;
    catalog.sources.brightPixPhotonCount(ID) = nBrightest;
    catalog.sources.radius(ID) = radius;
    catalog.sources.nSourcePixels(ID) = sum(apertureRegion(:));
    catalog.sources.nZeroPixels(ID) = apertureNZeroPixels;
    catalog.sources.photonCount(ID) = aperturePhotonCountCurrent;
    catalog.sources.localBackgroundPerPixel(ID) = localBackground./nSamplePixels;
    catalog.sources.photonCountBackgroundCorrected(ID) = aperturePhotonCountCurrent - catalog.sources.localBackgroundPerPixel(ID).*(catalog.sources.nSourcePixels(ID)-apertureNZeroPixels);

    % If subtracting background results in a count that is zero or less,
    % discard these results. Also give updates on progress.
    if catalog.sources.photonCountBackgroundCorrected(ID) < 1
        fprintf('%s - abandoned source (ID: %g). Brightest source pixel: %g photons. All source pixels: %g photons.\n',datestr(now),ID,nBrightest,catalog.sources.photonCountBackgroundCorrected(ID));
        catalog.sources.abandoned.brightPixLocX(abandonedID) = catalog.sources.brightPixLocX(ID);
        catalog.sources.abandoned.brightPixLocY(abandonedID) = catalog.sources.brightPixLocY(ID);
        catalog.sources.abandoned.brightPixPhotonCount(abandonedID) = catalog.sources.brightPixPhotonCount(ID);
        catalog.sources.abandoned.radius(abandonedID) = catalog.sources.radius(ID);
        catalog.sources.abandoned.nSourcePixels(abandonedID) = catalog.sources.nSourcePixels(ID);
        catalog.sources.abandoned.nZeroPixels(abandonedID) = catalog.sources.nZeroPixels(ID);
        catalog.sources.abandoned.photonCount(abandonedID) = catalog.sources.photonCount(ID);
        catalog.sources.abandoned.localBackgroundPerPixel(abandonedID) = catalog.sources.localBackgroundPerPixel(ID);
        catalog.sources.abandoned.photonCountBackgroundCorrected(abandonedID) = catalog.sources.photonCountBackgroundCorrected(ID);
        ID = ID - 1;
        abandonedID = abandonedID + 1;
    else
        fprintf('%s - processed source (ID: %g). Brightest source pixel: %g photons. All source pixels: %g photons.\n',datestr(now),ID,nBrightest,catalog.sources.photonCountBackgroundCorrected(ID));
    end
      
end
    
% How many sources?
catalog.sources.nSources = length(catalog.sources.photonCountBackgroundCorrected);

end