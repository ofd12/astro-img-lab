function catalog = A1_SourceDetect(catalog_in,n)
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

thresholdHigh = 36000;
thresholdLow = catalog.analysis.backgroundGeneral.muHat+(n.*catalog.analysis.backgroundGeneral.sigmaHat);

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
indicesRangeInterest = find(sorted(:,1)>=thresholdLow & sorted(:,1)<=thresholdHigh);

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
catalog.analysis.sourceThresholdHigh = thresholdHigh;
catalog.analysis.sourceThresholdLow = thresholdLow;
catalog.analysis.sourceThresholdLowNSigma = n;

end