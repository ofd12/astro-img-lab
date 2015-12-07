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
    % Find sources satisfying condition
	boolCentral = (catalog.sources.magnitude < catalog.results.magnitudeLimit(i));
    boolUpperBound = ((catalog.sources.magnitude-catalog.sources.magnitudeErr)<catalog.results.magnitudeLimit(i));
    boolLowerBound = ((catalog.sources.magnitude+catalog.sources.magnitudeErr)<catalog.results.magnitudeLimit(i));
    % Count sources satisfying condition
	catalog.results.nSourcesFluxLimit(i) = sum(boolCentral(:));
    catalog.results.nSourcesFluxLimitLowerBound(i) = sum(boolLowerBound(:));
    catalog.results.nSourcesFluxLimitUpperBound(i) = sum(boolUpperBound(:));
end

figure;
hold on;
title('N vs m; upper and lower bounds')
plot(catalog.results.magnitudeLimit,catalog.results.nSourcesFluxLimit,'go');
plot(catalog.results.magnitudeLimit,catalog.results.nSourcesFluxLimitLowerBound,'ro');
plot(catalog.results.magnitudeLimit,catalog.results.nSourcesFluxLimitUpperBound,'bo');
legend('N_{central}','N_{lower}','N_{upper}');
hold off;

catalog.results.nSourcesFluxLimitErrorPositive = catalog.results.nSourcesFluxLimit.^0.5 + (catalog.results.nSourcesFluxLimitUpperBound-catalog.results.nSourcesFluxLimit);
catalog.results.nSourcesFluxLimitErrorNegative = catalog.results.nSourcesFluxLimit.^0.5 + (catalog.results.nSourcesFluxLimit-catalog.results.nSourcesFluxLimitLowerBound);

figure;
hold on;
title('N vs m; with errors')
plot(catalog.results.magnitudeLimit,catalog.results.nSourcesFluxLimit,'go');
plot(catalog.results.magnitudeLimit,catalog.results.nSourcesFluxLimit+catalog.results.nSourcesFluxLimitErrorPositive,'ro');
plot(catalog.results.magnitudeLimit,catalog.results.nSourcesFluxLimit-catalog.results.nSourcesFluxLimitErrorNegative,'bo');
legend('N_{central}','N + \sigma_{upper}','N - \sigma_{lower}');
hold off;

catalog.results.log10nSourcesFluxLimit = log10(catalog.results.nSourcesFluxLimit);
catalog.results.log10nSourcesFluxLimitErrorPositive = catalog.results.nSourcesFluxLimitErrorPositive./(catalog.results.nSourcesFluxLimit.*log(10));
catalog.results.log10nSourcesFluxLimitErrorNegative = catalog.results.nSourcesFluxLimitErrorNegative./(catalog.results.nSourcesFluxLimit.*log(10));

figure;
hold on;
title('log_{10}(N) vs m; with errors')
plot(catalog.results.magnitudeLimit,catalog.results.log10nSourcesFluxLimit,'go');
plot(catalog.results.magnitudeLimit,catalog.results.log10nSourcesFluxLimit+catalog.results.log10nSourcesFluxLimitErrorPositive,'ro');
plot(catalog.results.magnitudeLimit,catalog.results.log10nSourcesFluxLimit-catalog.results.log10nSourcesFluxLimitErrorNegative,'bo');
legend('log_{10}(N)','log_{10}(N) + \sigma_{upper}','log_{10}(N) - \sigma_{lower}');
hold off;

% Write results to a csv file with columns: m, N(m)
filename = sprintf('A1_Results_%s.csv',datestr(now,'yyyy-mm-dd_HHMMSS'));
results = horzcat(catalog.results.magnitudeLimit',catalog.results.log10nSourcesFluxLimit');
errors = horzcat(catalog.results.log10nSourcesFluxLimitErrorNegative',catalog.results.log10nSourcesFluxLimitErrorPositive');
writeThis = horzcat(results,errors);
% Ignore first row as this has N = 0
writeThis(1,:) = [];
csvwrite(filename,writeThis);

end