clear;
%% A1 - Script
catalog = A1_init('A1_mosaic.fits');

%% Crop out edges as they are fuzzy - store data in catalog.image
catalog = A1_Crop(catalog,130);

%% Manually remove nearby stars from image - find pixel coordinates in DS9
catalog = A1_Removal(catalog);

%% Reassign counts of >36000 to =36000 as this is the upper limit of reliability
catalog = A1_Ceiling(catalog,36000);

%% Do Gaussian fitting of general background
catalog = A1_BackgroundAnalysis(catalog,3360,3480);

%% Detect sources in image
% generates copy of the image in catalog,
% but only for pixels with photon counts within a certain range
% non-source pixels will be set to have zero counts
catalog = A1_SourceDetect(catalog,5);

%% Write above new image to new FITS file for viewing in DS9
fitswrite(catalog.analysis.sourcePixels,sprintf('%s%g%s%g%s%g%s','A1_mosaicSources__',catalog.analysis.sourceThresholdLowNSigma,'_sigma__',catalog.analysis.sourceThresholdLow,'_to_',catalog.analysis.sourceThresholdHigh,'_counts.fits'));

%% Process sources
catalog = A1_Cluster(catalog,35);

%% Find magnitudes
catalog = A1_Magnitude(catalog);
