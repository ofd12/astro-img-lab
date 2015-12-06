function catalog = A1_Removal(catalog_in)
%% Amend manually depending on what needs to be removed from image:
% Nearby stars, blooming etc

% Check thing exists
if (~exist('catalog_in','var') || ~isstruct(catalog_in))
    error('First argument is not specified or is not a structure array.');
end

catalog = catalog_in;
removal = struct();

removal.starcoordinates.centre.x = [434,855,778,2006,2141,1333,1309,2009];
removal.starcoordinates.centre.y = [3969,2646,2154,2181,3174,3902,3080,3630];
removal.starcoordinates.radius = [33,60,54,33,48,34,312,41];
removal.starcoordinates.radiusError = [1,2,2,1,1,1,5,1];

removal.starcoordinates.topleft.x = [589,1929];
removal.starcoordinates.topleft.y = [3244,1328];
removal.starcoordinates.bottomright.x = [706,1983];
removal.starcoordinates.bottomright.y = [3126,1277];

removal.bloomingboxes.topleft.x = [2002,642,840,773,1296,1230];
removal.bloomingboxes.topleft.y = [3672,3288,2705,2226,4352,22];
removal.bloomingboxes.bottomright.x = [2007,650,849,779,1321,1367];
removal.bloomingboxes.bottomright.y = [3577,3072,2573,2093,1,1];

removal.savestar.centre.x = 831;
removal.savestar.centre.y = 2693;
removal.savestar.radius = 8;
removal.savestar.radiusError = 1;

removal.bloomingtri.topleft.x = [1193,969,1224,1181,887,1261,1230,1278];
removal.bloomingtri.topleft.y = [340,304,240,203,192,137,17,34];
removal.bloomingtri.bottomright.x = [1439,1525,1394,1575,1181,1349,4,1298];
removal.bloomingtri.bottomright.y = [296,295,185,183,185,88,1,16];

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

for i = 1:length(removal.bloomingtri.topleft.x)
    PixelTopLeft = [removal.bloomingtri.topleft.x(i),removal.bloomingtri.topleft.y(i)];
    PixelBottomRight = [removal.bloomingtri.bottomright.x(i),removal.bloomingtri.bottomright.y(i)];
    catalog = A1_StarRemovalRectangular(catalog,PixelTopLeft,PixelBottomRight);
end

end