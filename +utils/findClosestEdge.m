function edge = findClosestEdge(board, coordinates)

% -------------------------------------------------------------------------
% This function finds the edge closest to the specified coordinates. Note
% that this function returns 0 on an error.
%
% Arguments (required)
% - board           Board       Board object
% - coordinates     [Int, Int]  (x,y)-coordinates of estimation
% -------------------------------------------------------------------------

% Set placeholder for node distances and return value
distances = zeros(length(board.nodes), 1); edge = 0;

% For each node...
for i = 1:length(board.nodes)
    
    % Get the distance between the estimate and the node coordinates
    distances(i) = norm(coordinates(:) - board.nodes{i}.coordinates(:));
    
end

% Sort the nodes in order of increasing distance
[~, idx] = sort(distances, 'ascend'); idx = idx(:);

% Find the edge that connects the two nearest nodes
for i = 1:length(board.edges)
    if isequal(board.edges{i}.nodePair(:), idx(1:2)) || ...
            isequal(board.edges{i}.nodePair(:), idx(2:-1:1))
        % If the edge is round, return the index. Else, return 0.
        edge = i; return
    end
    
end

end