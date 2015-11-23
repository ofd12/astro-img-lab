function catalog = A1_OLD_VECTORISED_SourceDetect(catalog_in,thresholdLow,thresholdHigh)
%% Copies image from FITS file but only includes pixels with counts in specified range
% catalog_in:       struct, catalog_in.image.data contains info from fitsread(file)
% thresholdLow:     lower bound of pixel count range of interest
% thresholdHigh:    upper bound of pixel count range of interest
% NB "pixel count" is number of photons detected by that pixel on the CCD
%   i.e. number of electrons produced and then counted

% error handling for incorrect input
if ( ~exist('catalog_in','var') || ~isstruct(catalog_in) )
    error('First argument is not specified or is not a structure array.');
end

catalog = catalog_in;

% default values for thresholdLow and thresholdHigh (maximum sensible range)
DEFAULT_thresholdLow = 3000;
DEFAULT_thresholdHigh = 50000;

% error handling for bad / nonexistent threshold values
if ( ~exist('thresholdLow','var') || ~exist('thresholdHigh','var') )
    thresholdLow = DEFAULT_thresholdLow;
    thresholdHigh = DEFAULT_thresholdHigh;
elseif (thresholdLow > thresholdHigh)
    fprintf('Lower bound (arg2) cannot be greater than higher bound (arg3)!\n');
    fprintf('   User specified %g and %g respectively.\n',thresholdLow,thresholdHigh);
    fprintf('   Reset values to default maximum limits %g and %g respectively.\n',DEFAULT_thresholdLow,DEFAULT_thresholdHigh);
    thresholdLow = DEFAULT_thresholdLow;
    thresholdHigh = DEFAULT_thresholdHigh;
elseif ( (thresholdLow < DEFAULT_thresholdLow) || (thresholdHigh > DEFAULT_thresholdHigh) )
    fprintf('User-input thresholds exceed allowed range of %g to %g counts.\n',DEFAULT_thresholdLow,DEFAULT_thresholdHigh);
    fprintf('   User specified %g and %g respectively.\n',thresholdLow,thresholdHigh);
    fprintf('   Reset values to default maximum limits %g and %g respectively.\n',DEFAULT_thresholdLow,DEFAULT_thresholdHigh);
    thresholdLow = DEFAULT_thresholdLow;
    thresholdHigh = DEFAULT_thresholdHigh;
end

% listed: nPixels x 2 matrix
listed = nan(catalog.image.nPixels,2);
% 1st column are the pixel counts in order of increasing linear index
listed(:,1) = catalog.image.data(:);
% 2nd column is linear index for pixel counts in 1st column
%   (index of these pixels in original image)
listed(:,2) = 1:catalog.image.nPixels;

% sorted: 'listed' matrix sorted according to pixel count (column 1)
%   lowest counts at the top of the matrix
%   sortrows preserves the rows
sorted = sortrows(listed,1);

% indicesRangeInterest: linear indices of the sorted elements which fall within the range of interest
%   (indices within 'sorted' matrix - NOT THE SAME as indices in original image)
%   count range of interest is ( thresholdLow < count < thresholdHigh )
indicesRangeInterest = find(sorted(:,1)>thresholdLow & sorted(:,1)<thresholdHigh);

% sortedRangeInterest: sorted matrix, excluding elements not in the range of interest
sortedRangeInterest = sorted(indicesRangeInterest,:);

% imageSource: matrix with same dimensions of original image
% contains pixel counts in 'sortedRangeInterest' - "source pixels"
% "non-source pixels" will be shown to have zero count
imageSource = zeros(catalog.image.dimensions(1), catalog.image.dimensions(2));
imageSource(sortedRangeInterest(:,2)) = sortedRangeInterest(:,1);

% nSourcePixels: number of pixels in image which are attributed to a source
nSourcePixels = size(find(imageSource));
% store nSourcePixels in 'catalog' struct
catalog.analysis.nSourcePixels = nSourcePixels(1);
% store 'imageSource' matrix in 'catalog' struct
catalog.analysis.sourcePixels = imageSource;
% store thresholds in 'catalog' for future reference
catalog.analysis.thresholdHigh = thresholdHigh;
catalog.analysis.thresholdLow = thresholdLow;

end