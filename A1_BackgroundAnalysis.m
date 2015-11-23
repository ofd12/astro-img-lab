function catalog = A1_BackgroundAnalysis(catalog_in,lowerBound,upperBound)
%% Plot histogram of pixel counts and fit Gaussian to it

if (~exist('catalog_in','var') || ~isstruct(catalog_in))
    error('First argument is not specified or is not a structure array.');
end
if (~exist('lower','var') || ~exist('upper','var') || upperBound<lowerBound)
    lowerBound = 3360;
    upperBound = 3480;
end

catalog = catalog_in;

backgroundReducedRange = catalog.image.data(find(catalog.image.data(:)>lowerBound & catalog.image.data(:)<upperBound));

figure('Name','background_histfit');

% create histogram of localised background data
h = histogram(backgroundReducedRange);

hold('on');
% estimate parameters for fit of data to normal distribution
[muhat,sigmahat,muci,sigmaci] = normfit(backgroundReducedRange);
x = linspace(lowerBound,upperBound,100);
scaleFactor = max(h.Values)./normpdf(muhat,muhat,sigmahat);
plot(x,scaleFactor.*normpdf(x,muhat,sigmahat),'-r');

title(sprintf('Histogram of background counts, with Gaussian fit: %g to %g counts\nFit parameters: [\\mu,\\sigma] = [%g,%g]',lowerBound,upperBound,muhat,sigmahat));
xlabel('Pixel counts (number of photons)');
ylabel('Number of pixels');

hold('off');

catalog.analysis.backgroundGeneral.desc = sprintf('Gaussian fit of background from %g to %g counts',lowerBound,upperBound);
catalog.analysis.backgroundGeneral.muHat = muhat;
catalog.analysis.backgroundGeneral.sigmaHat = sigmahat;
catalog.analysis.backgroundGeneral.muCI = muci;
catalog.analysis.backgroundGeneral.sigmaCI = sigmaci;

end