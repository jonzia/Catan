function node = findClosestTile(board, coordinates)

% -------------------------------------------------------------------------
% This function finds the tile closest to the specified coordinates.
%
% Arguments (required)
% - board           Board       Board object
% - coordinates     [Int, Int]  (x,y)-coordinates of estimation
% -------------------------------------------------------------------------

% Set placeholder for tile distances
distances = zeros(length(board.tiles), 1);

% For each node...
for i = 1:length(board.tiles)
    
    % Get the distance between the estimate and the node coordinates
    distances(i) = norm(coordinates(:) - board.tiles{i}.centerpoint(:));
    
end

% Return the index with the minimum distance
[~, node] = min(distances);

end

