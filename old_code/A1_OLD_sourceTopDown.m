function catalog = A1_OLD_sourceTopDown(catalog_in)
catalog = catalog_in;
catalog.analysis.sourceBool = zeros(catalog.image.dimensions(1), catalog.image.dimensions(2));
thresholdHigh = 50000;
thresholdLow =  3500;
count = 1e9;
image = catalog.image.data;
ctr = 0; %%%
N = catalog.image.dimensions(1).*catalog.image.dimensions(2); %%%

while count >= thresholdLow 
    ctr = ctr + 1; %%%
    [count,loc] = max(image(:));
    [i,j] = ind2sub(size(image),loc);
    image(i,j) = 0;
    if count <= thresholdHigh
        catalog.analysis.sourceBool(i,j) = 1;
    end
    if (rem(ctr,1000) == 0 || ctr == 1)
        fprintf('%s%s%g%s%g%s\n',datestr(now),' : ',ctr,' of ',N,' pixels analysed.');
    end
end
nSources = size(find(catalog.analysis.sourceBool));
catalog.analysis.nSources = nSources(1);
catalog.analysis.sourceCounts = catalog.image.data.*catalog.analysis.sourceBool;

catalog.analysis.thresholdHigh = thresholdHigh;
catalog.analysis.thresholdLow = thresholdLow;

end
