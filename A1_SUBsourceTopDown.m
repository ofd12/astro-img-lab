function catalog = A1_SUBsourceTopDown(catalog_in)
catalog = catalog_in;
catalog.sub.analysis.sourceBool = zeros(catalog.sub.image.dimensions(1), catalog.sub.image.dimensions(2));
thresholdHigh = 50000;
thresholdLow =  3500;
count = 1e9;
image = catalog.sub.image.data;

while count >= thresholdLow 
    [count,loc] = max(image(:));
    [i,j] = ind2sub(size(image),loc);
    image(i,j) = 0;
    if count <= thresholdHigh
        catalog.sub.analysis.sourceBool(i,j) = 1;
    end
end
nSources = size(find(catalog.sub.analysis.sourceBool));
catalog.sub.analysis.nSources = nSources(1);
catalog.sub.analysis.sourceCounts = catalog.sub.image.data.*catalog.sub.analysis.sourceBool;

end
