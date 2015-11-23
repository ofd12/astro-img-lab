function catalog = A1_Ceiling(catalog_in, ceiling)
%% Reassign counts of >ceiling to =ceiling

% error handling for incorrect input
if ( ~exist('catalog_in','var') || ~isstruct(catalog_in) )
    error('First argument is not specified or is not a structure array.');
end

catalog = catalog_in;
% reassign values
catalog.image.data(catalog.image.data>ceiling) = ceiling;

end