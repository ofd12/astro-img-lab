%% State filename - to be done manually!
filename = 'A1_mosaic.fits';

%% Store data from the FITS file
% catalog: struct to store analysis information
catalog = struct();
% about: information about the authors
% info: struct containing info about FITS file
%   info.PrimaryData.Keywords contains lots of information
% image: 4611 x 2570 double of the electron counts for each pixel
% fitsdisp(filename) does displays some more info
catalog.about = 'MATLAB program created by Oscar Denihan and Rachel Sleet for Imperial College London MSci Physics Year 3 Lab - A1 Astronomical Image Processing';
catalog.info = fitsinfo(filename);
catalog.image.data = fitsread(filename);
catalog.image.dimensions = size(catalog.image.data);

% take subsection for easier understanding:
%   so handle 10 000 data points instead of 12 000 000
catalog.sub.image.data = catalog.image.data((4611-1246:4611-1146),(930:1030));
catalog.sub.image.dimensions = size(catalog.sub.image.data);


% catalog = A1_sourceDetect(catalog);
% catalog = A1_SUBsourceDetect(catalog);

catalog = A1_sourceTopDown(catalog);
% catalog = A1_SUBsourceTopDown(catalog);

fprintf('%s%g%s%g%s\n','Man got ',catalog.analysis.nSources,' source pixels (',catalog.image.dimensions(1)*catalog.image.dimensions(2),' total pixels) u kno!');
% fprintf('%s%g%s%g%s\n','Man got ',catalog.sub.analysis.nSources,' source pixels (',catalog.sub.image.dimensions(1)*catalog.sub.image.dimensions(2),' total pixels) u kno!');

% write new image to new FITS file for viewing in DS9

fitswrite(catalog.analysis.sourceCounts,sprintf('%s%g%s%g%s','A1_mosaicSources-',catalog.analysis.thresholdLow,'-',catalog.analysis.thresholdHigh,'counts'));
% fitswrite(catalog.sub.analysis.sourceCounts,'toy.fits');


% MASKING - essentially copy the image but remove some of the data
%   e.g. noisy edges, bloom, stars nearby