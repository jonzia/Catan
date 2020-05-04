function node = findClosestNode(board, coordinates)

% -------------------------------------------------------------------------
% This function finds the node closest to the specified coordinates.
%
% Arguments (required)
% - board           Board       Board object
% - coordinates     [Int, Int]  (x,y)-coordinates of estimation
% -------------------------------------------------------------------------

% Set placeholder for node distances
distances = zeros(length(board.nodes), 1);

% For each node...
for i = 1:length(board.nodes)
    
    % Get the distance between the estimate and the node coordinates
    distances(i) = norm(coordinates(:) - board.nodes{i}.coordinates(:));
    
end

% Return the index with the minimum distance
[~, node] = min(distances);

end

