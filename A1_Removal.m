function catalog = A1_Removal(catalog_in)
%% Amend manually depending on what needs to be removed from image:
% Nearby stars, blooming etc

% Check thing exists
if (~exist('catalog_in','var') || ~isstruct(catalog_in))
    error('First argument is not specified or is not a structure array.');
end

catalog = catalog_in;
removal = struct();

removal.starcoordinates.centre.x = [1458,561,1434];
removal.starcoordinates.centre.y = [4032,4098,3204];
removal.starcoordinates.radius = [24,25,227];
removal.starcoordinates.radiusError = [1,1,15];

removal.starcoordinates.topleft.x = [2063,2107,2227,2103,731,937,871];
removal.starcoordinates.topleft.y = [1454,2336,3331,3787,3363,2810,2320];
removal.starcoordinates.bottomright.x = [2117,2157,2294,2166,820,1010,942];
removal.starcoordinates.bottomright.y = [1401,2285,3262,3727,3277,2739,2250];

removal.bloomingboxes.topleft.x = [2132,772,970,903,1426];
removal.bloomingboxes.topleft.y = [3802,3418,2835,2356,4609];
removal.bloomingboxes.bottomright.x = [2137,780,979,909,1451];
removal.bloomingboxes.bottomright.y = [3707,3202,2703,2223,10];

%% Circular aperture removal:
for i = 1:length(removal.starcoordinates.radius)
    xCentre = removal.starcoordinates.centre.x(i);
    yCentre = removal.starcoordinates.centre.y(i);
    radius = removal.starcoordinates.radius(i);
    catalog = A1_StarRemovalCircular(catalog,xCentre,yCentre,radius);
end

%% Rectangular aperture removal:
for i = 1:length(removal.starcoordinates.topleft.x)
    PixelTopLeft = [removal.starcoordinates.topleft.x(i),removal.starcoordinates.topleft.y(i)];
    PixelBottomRight = [removal.starcoordinates.bottomright.x(i),removal.starcoordinates.bottomright.y(i)];
    catalog = A1_StarRemovalRectangular(catalog,PixelTopLeft,PixelBottomRight);
end

for i = 1:length(removal.bloomingboxes.topleft.x)
    PixelTopLeft = [removal.bloomingboxes.topleft.x(i),removal.bloomingboxes.topleft.y(i)];
    PixelBottomRight = [removal.bloomingboxes.bottomright.x(i),removal.bloomingboxes.bottomright.y(i)];
    catalog = A1_StarRemovalRectangular(catalog,PixelTopLeft,PixelBottomRight);
end

end