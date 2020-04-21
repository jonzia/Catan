function plotBoard(obj, varargin)

% -------------------------------------------------------------------------
% This function plots the game board based on the current state.
% -------------------------------------------------------------------------

% Initialize the figure
figure; hold on; set(gca, 'Visible', 'off')

% For each tile...
for i = 1:19
    
    % Get the x and y coordinates of the tile hexagon
    [x, y] = utils.hexagon(obj.tiles{i}.centerpoint(1), obj.tiles{i}.centerpoint(2));
    
    % Set color of the hexagon based on tile resource
    switch obj.tiles{i}.resource
        case Resource.brick
            color = [0.6350 0.0780 0.1840];
        case Resource.desert
            color = [0 0 0];
        case Resource.sheep
            color = [0.4660 0.6740 0.1880];
        case Resource.stone
            color = [0.5 0.5 0.5];
        case Resource.wheat
            color = [0.9290 0.6940 0.1250];
        case Resource.wood
            color = [0.4510 0.3220 0.2930];
    end
    
    % Plot the hexagon
    plot(x, y, '-k'); fill(x, y, color, 'FaceAlpha', 0.5);
    
    % List the tile number
    text(obj.tiles{i}.centerpoint(1), obj.tiles{i}.centerpoint(2), ...
        string(obj.tiles{i}.number), 'Color', [1 1 1])
    
end

% For each node...
for i = 1:length(obj.nodes)
    % Plot the node on a scatterplot
    scatter(obj.nodes{i}.coordinates(1), obj.nodes{i}.coordinates(2), 'MarkerFaceColor', 'k')
    % Plot the node label
    text(obj.nodes{i}.coordinates(1), obj.nodes{i}.coordinates(2), "Node " + string(i), 'Color', 'r')
end

% Highlight an edge
% edgeNumber = 5;
% idx = find(A == edgeNumber, 1);
% [i, j] = ind2sub(size(A), idx);
% plot([nodes(1, i), nodes(1, j)], [nodes(2, i), nodes(2, j)], '-k', 'LineWidth', 2)

end

