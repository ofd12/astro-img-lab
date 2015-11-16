%% State filename - to be done manually!
filename = 'A1_mosaic.fits';

%% Store data from the FITS file
% catalog: struct to store analysis information
catalog = struct();
% about: information about the authors
% info: struct containing info about FITS file
%   info.PrimaryData.Keywords contains lots of information
% image: 4611 x 2570 double of the electron counts for each pixel
% fitsdisp(filename) also displays some more info
catalog.about = 'MATLAB program created by Oscar Denihan and Rachel Sleet for Imperial College London MSci Physics Year 3 Lab - A1 Astronomical Image Processing';
catalog.info = fitsinfo(filename);
catalog.image.data = fitsread(filename);
catalog.image.dimensions = size(catalog.image.data);
catalog.image.nPixels = catalog.image.dimensions(1).*catalog.image.dimensions(2);

%% Take a small section of image?
%  catalog.sub.image.data = catalog.image.data((4611-1246:4611-1146),(930:1030));
%  catalog.sub.image.dimensions = size(catalog.sub.image.data);

%% Detect sources in image
% generates copy of the image in catalog,
% but only for pixels with photon counts within a certain range
% non-source pixels will be set to have zero counts
catalog = A1_SourceDetect(catalog,3000,36000);

%% Write above new image to new FITS file for viewing in DS9
fitswrite(catalog.analysis.sourcePixels,sprintf('%s%g%s%g%s','A1_mosaicSources_',catalog.analysis.thresholdLow,'_to_',catalog.analysis.thresholdHigh,'_counts.fits'));

% MASKING - essentially copy the image but remove some of the data
%   e.g. noisy edges, bloom, stars nearby