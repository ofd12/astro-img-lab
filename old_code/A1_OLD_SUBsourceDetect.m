function catalog = A1_OLD_SUBsourceDetect(catalog_in)

% error handling for incoorrect input
if (~isstruct(catalog_in))
    error('Input argument must be a struct!');
end

catalog = catalog_in;
data = catalog.sub.image.data;

% numbers of elements in x and y directions
Nx = catalog.sub.image.dimensions(2);
Ny = catalog.sub.image.dimensions(1);

%% Consider each element
% is it greater than or equal to all the elements around it?
% ignore edges - these will be masked anyway due to edge effects
% local maximum matrix
%   - boolean to indicate which elements greater than all their adjacents
local_max = zeros(Ny, Nx);
% counting limit due to breakdown of linearity
c_lim = 50000;
% border - how many pixels in from the edge will we exclude?
% found to be same on all edges (use 1 for SUBsourceDetect)
border = 1;

for i = (1+border):(Ny-border)
    for j = (1+border):(Nx-border)
        pt = data(i,j);
        % check below counting limit
        if pt < c_lim
            % left, right, up, down
            if ( pt >= data(i,j-1) && pt >= data(i,j+1) && pt >= data(i-1,j) && pt >= data(i+1,j) )
                % top left, top right, bottom left, bottom right
                if ( pt >= data(i-1,j-1) && pt >= data(i+1,j-1) && pt >= data(i-1,j+1) && pt >= data(i+1,j+1) )
                    local_max(i,j) = 1;
                end
            end
        end 
    end
end

% matrix, same dimensions as image - values are 1 or 0:
%   does that pixel represent a source?
catalog.sub.analysis.sourceBool = local_max;
% what does the image look like with only the point sources?
catalog.sub.analysis.sourceCounts = catalog.sub.image.data.*catalog.sub.analysis.sourceBool;
% how many sources are there?
nSources = size(find(catalog.sub.analysis.sourceBool));
catalog.sub.analysis.nSources = nSources(1);

end