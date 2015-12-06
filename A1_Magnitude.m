function catalog = A1_Magnitude(catalog_in)
%% Convert counts into calibrated magnitudes via instrumental magnitudes
% Check thing exists
if (~exist('catalog_in','var') || ~isstruct(catalog_in))
    error('First argument is not specified or is not a structure array.');
end
catalog = catalog_in;

% Instrumental zero point and its error from MAGZPT and MAGZRR respectively in catalog.info.PrimaryData.Keywords
ZP_inst = 25.3000;
ZP_inst_err = 0.0200;

% Calculate instrumental magnitudes
catalog.sources.magnitudeInst = -2.5.*log10(catalog.sources.photonCountBackgroundCorrected);

% Calculate calibrated magnitudes
catalog.sources.magnitude = catalog.sources.magnitudeInst + ZP_inst;

% Calculate error on calibrated magnitudes
catalog.sources.magnitudeErr = ( (ZP_inst_err.^2) + ((-2.5./(catalog.sources.photonCountBackgroundCorrected.*log(10))).^2).*(catalog.sources.photonCountBackgroundCorrected.^0.5) ).^0.5;

% Calculate how many sources (and the logarithm base 10 thereof) which are brighter than a specific magnitude
catalog.results.magnitudeLimit = linspace(min(catalog.sources.magnitude(:)),max(catalog.sources.magnitude(:)),72);
for i = 1:length(catalog.results.magnitudeLimit)
	bool = (catalog.sources.magnitude <= catalog.results.magnitudeLimit(i));
	catalog.results.nSourcesFluxLimit(i) = sum(bool(:));
end
catalog.results.log10nSourcesFluxLimit = log10(catalog.results.nSourcesFluxLimit);

% Write results to a csv file with columns: m, N(m)
filename = sprintf('A1_Results_%s.csv',datestr(now,'yyyy-mm-dd_HHMMSS'));
results = horzcat(catalog.results.magnitudeLimit',catalog.results.log10nSourcesFluxLimit');
csvwrite(filename,results);

end