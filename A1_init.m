function catalog = A1_init(filename)
%% Initialise from 'filename'.fits

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
catalog.imageOriginal.data = fitsread(filename);
catalog.imageOriginal.dimensions = size(catalog.imageOriginal.data);
catalog.imageOriginal.nPixels = catalog.imageOriginal.dimensions(1).*catalog.imageOriginal.dimensions(2);

end