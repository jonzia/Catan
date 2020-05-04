function varargout = plotBoard(obj, varargin)

% -------------------------------------------------------------------------
% This function plots the game board based on the current state.
%
% Arguments (optional):
% - handle      fig     Figure handle, if figure already initialized
%
% Outputs (optional):
% - 
% -------------------------------------------------------------------------

% Set player colors
colors = {[0 0.4770 0.7410], [0.4660 0.6740 0.1880], ...
    [0.8500 0.3250 0.0980], [0.6350 0.0780 0.1840], ...
    [0.4940 0.1840 0.5560], [0.9290 0.6940 0.1250]};

% Initialize the figure
if isempty(varargin); f = figure; else; f = gcf; clf; end
hold on; set(gca, 'Visible', 'off')

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
    if ~obj.tiles{i}.hasThief
        % If the tile doesn't have the thief, plot normally
        text(obj.tiles{i}.centerpoint(1) - 0.1, obj.tiles{i}.centerpoint(2), ...
            string(obj.tiles{i}.number), 'Color', [1 1 1], 'FontSize', 16)
    else
        % Else, indicate that the tile has the thief
        text(obj.tiles{i}.centerpoint(1) - 0.1, obj.tiles{i}.centerpoint(2), ...
            string(obj.tiles{i}.number) + " (T)", 'Color', [1 1 1], 'FontSize', 16)
    end
    
end

% For each node...
for i = 1:length(obj.nodes)
    
    % Plot the node on a scatterplot
    scatter(obj.nodes{i}.coordinates(1), obj.nodes{i}.coordinates(2), ...
        'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k')
    % Plot the node label
    text(obj.nodes{i}.coordinates(1) + 0.1, obj.nodes{i}.coordinates(2), ...
        "Node " + string(i), 'Color', 'k')
    
    % If the node has a harbor, indicate the harbor
    if ~isempty(obj.nodes{i}.harbor)
        text(obj.nodes{i}.coordinates(1) + 0.1, obj.nodes{i}.coordinates(2) - 0.25, ...
            "Harbor: " + string(obj.nodes{i}.harbor.resource))
    end
    
    % If the node has a house or city, plot a modified marker TODO
    if obj.nodes{i}.structure ~= Structure.none
        
        % Set player color
        color = colors{obj.nodes{i}.player};
        
        switch obj.nodes{i}.structure
            case Structure.house
                scatter(obj.nodes{i}.coordinates(1), obj.nodes{i}.coordinates(2), ...
                    'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'SizeData', 100)
            case Structure.city
                scatter(obj.nodes{i}.coordinates(1), obj.nodes{i}.coordinates(2), ...
                    'square', 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'SizeData', 100)
        end
    end
    
end

% For each edge...
for i = 1:length(obj.edges)
    % If the edge has a structure...
    if obj.edges{i}.structure ~= Structure.none
        
        % Set player color
        color = colors{obj.edges{i}.player};
        
        % Get the starting and ending nodes
        startNode = obj.nodes{obj.edges{i}.nodePair(1)}.coordinates;
        endNode = obj.nodes{obj.edges{i}.nodePair(2)}.coordinates;
        
        % Plot a road in between the nodes
        plot([startNode(1) endNode(1)], [startNode(2) endNode(2)], 'LineWidth', 3, 'Color', color)
        
    end
end

% Set output arguments
if nargout > 0; varargout{1} = f; end

end

