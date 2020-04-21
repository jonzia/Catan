function obj = initialize(obj, varargin)

% -------------------------------------------------------------------------
% This function initializes the board by selecting the order of tiles and
% numbers, and defining all nodes and edges of the board.
% -------------------------------------------------------------------------

% Specify how many of each hexagonal tile is present
numBrick = 3; numDesert = 1; numSheep = 4;
numStone = 3; numWheat = 4; numWood = 4;

% For each of the 19 tiles, select a resource from the available resources
resources = [];     % Set placeholder for tile resources
for i = 1:19
    
    % Assign a resource to the tile
    assigned = false;   % Flag to determine whether tile has been assigned
    while ~assigned
        
        % Select a random number from 1 to 6
        r = randi([1, 6]);
        
        % Use the random number to determine resources for the i^th tile
        switch r
            case 1; if numBrick > 0; resources = [resources Resource.brick]; ...
                        assigned = true; numBrick = numBrick - 1; end
            case 2; if numDesert > 0; resources = [resources Resource.desert]; ...
                        assigned = true; numDesert = numDesert - 1; end
            case 3; if numSheep > 0; resources = [resources Resource.sheep]; ...
                        assigned = true; numSheep = numSheep - 1; end
            case 4; if numStone > 0; resources = [resources Resource.stone]; ...
                        assigned = true; numStone = numStone - 1; end
            case 5; if numWheat > 0; resources = [resources Resource.wheat]; ...
                        assigned = true; numWheat = numWheat - 1; end
            case 6; if numWood > 0; resources = [resources Resource.wood]; ...
                        assigned = true; numWood = numWood - 1; end
        end
        
    end
    
end

% Numbering may begin with tiles 1, 3, 8, 12, 17, 19. The following
% assignment starts with tile 1:
assignment = [1, 4, 8, 13, 17, 18, 19, 16, 12, 7, 3, 2, 5, 9, 14, 15, 11, 6, 10];
% The following assignment starts with tile 3:
assignment = [assignment; 3, 2, 1, 4, 8, 13, 17, 18, 19, 16, 12, 7, 6, 5, 9, 14, 15, 11, 10];
% The following assignment starts with tile 8:
assignment = [assignment; 8, 13, 17, 18, 19, 16, 12, 7, 3, 2, 1, 4, 9, 14, 15, 11, 6, 5, 10];
% The following assignment starts with tile 12:
assignment = [assignment; 12, 7, 3, 2, 1, 4, 8, 13, 17, 18, 19, 16, 11, 6, 5, 9, 14, 15, 10];
% The following assignment starts with tile 17:
assignment = [assignment; 17, 18, 19, 16, 12, 7, 3, 2, 1, 4, 8, 13, 14, 15, 11, 6, 5, 9, 10];
% The following assignment starts with tile 19:
assignment = [assignment; 19, 16, 12, 7, 3, 2, 1, 4, 8, 13, 17, 18, 15, 11, 6, 5, 9, 14, 10];

% Select an assignment at random
assignment = assignment(randi([1, 6]), :);

% The sequence of numbers corresponding to the assignment is as follows:
numbers = [5 2 6 3 8 10 9 12 11 4 8 10 9 4 5 6 3 11];

% Set tile centerpoints
x_start = 2*sin(pi/3)*(0:2); y_start = zeros(1, 3);
x_start = [x_start (2*sin(pi/3)*(0:3) - sin(pi/3))]; y_start = [y_start -1.5*ones(1, 4)];
x_start = [x_start (2*sin(pi/3)*(0:4) - 2*sin(pi/3))]; y_start = [y_start -3*ones(1, 5)];
x_start = [x_start (2*sin(pi/3)*(0:3) - sin(pi/3))]; y_start = [y_start -4.5*ones(1, 4)];
x_start = [x_start 2*sin(pi/3)*(0:2)]; y_start = [y_start -6*ones(1, 3)];

% For each tile, assign a resource and number
obj.tiles = cell(19, 1);    % Initialize placeholder for tiles
counter = 1;                % Initialize counter for number assignment
for i = 1:19
    % The i^th tile gets the i^th resource and number given by the order in
    % which the tiles were assigned the number sequence
    tile = assignment(i);   % Get the i^th tile
    if resources(tile) ~= Resource.desert
        obj.tiles{tile} = Tile(resources(tile), numbers(counter), [x_start(tile) y_start(tile)]);
        counter = counter + 1;  % Increment the counter
    else
        obj.tiles{tile} = Tile(resources(tile), 0, [x_start(tile) y_start(tile)]);
    end
end

% Set placeholder for node coordinates
nodes = [];

% Initialize board nodes on a tile-by-tile basis
for i = 1:19
    
    % Obtain x and y coordinates of each vertex of the tile hexagon
    [x, y] = utils.hexagon(x_start(i), y_start(i));
    
    % Define each vertex as a new node if it hasn't already been counted
    for j = 1:length(x)
        if ~isempty(nodes)
            temp = ismember(nodes', [x(j); y(j)]', 'rows');
            if isempty(find(temp == true, 1)); nodes = [nodes [x(j); y(j)]]; end
        else; nodes = [x(j); y(j)];
        end
    end
    
end

% Get the number of unique nodes in the board
numNodes = size(nodes, 2);

% Build an adjacency matrix weighted by edge number
A = zeros(numNodes); edgeCounter = 0;   % Initialize placeholders
for i = 1:numNodes
    for j = 1:numNodes
        % For each pair of non-identical nodes...
        if j == i; continue; end
        % ... which haven't already been assigned an edge...
        if A(i, j) ~= 0 || A(j, i) ~= 0; continue; end
        % ... if the nodes are close together, create a new edge
        if norm(nodes(:, i) - nodes(:, j)) < 1.1
            edgeCounter = edgeCounter + 1;
            A(i, j) = edgeCounter; A(j, i) = A(i, j);
        end
    end
end; obj.adjacency = A;

% Set placeholder for nodes
obj.nodes = cell(numNodes, 1);

% For each node...
for i = 1:numNodes
    
    % Instantiate the Node object
    obj.nodes{i} = Node(i, nodes(:, i));
    
    % For each tile...
    for j = 1:19
        % Determine whether the node lies on the hexagon
        [x, y] = utils.hexagon(obj.tiles{j}.centerpoint(1), obj.tiles{j}.centerpoint(2));
        temp = ismember([x(:) y(:)], obj.nodes{i}.coordinates', 'rows');
        % If so, add the tile to the node
        if ~isempty(find(temp == true, 1)); obj.nodes{i}.tiles = [obj.nodes{i}.tiles j]; end
    end
    
end

% Set placeholder for edges
obj.edges = cell(edgeCounter, 1);

% For each edge...
for i = 1:edgeCounter
    % Instantiate the Edge object
    obj.edges{i} = Edge(i);
end

end

