function [actions, log] = initialHouse(obj, player)

% -------------------------------------------------------------------------
% This function returns all possible actions corresponding to building an
% initial house and associated road.
% -------------------------------------------------------------------------

% Initialize action and log placeholders
actions = {}; log = {};

% Give the player the necessary resources to build a house and road
[obj, ~] = obj.tradeBank(player, Resource.brick, -2);
[obj, ~] = obj.tradeBank(player, Resource.sheep, -1);
[obj, ~] = obj.tradeBank(player, Resource.wheat, -1);
[obj, ~] = obj.tradeBank(player, Resource.wood, -2);

% For each valid node...
for i = 1:length(obj.nodes)
    [~, isValid] = obj.placeStructure(player, Structure.house, i);
    if ~isValid; continue; end
    % Return building a house and adjacent road as an action
    % For each valid adjacent edge...
    for j = 1:length(obj.edges)
        if (obj.edges{j}.nodePair(1) == i || obj.edges{j}.nodePair(2) == i) && ...
                obj.edges{j}.structure == Structure.none
            % Create a temporary object (for resource usage)
            temp = obj;
            % Place a house on the node and adjacent edge
            [temp, ~] = temp.placeStructure(player, Structure.house, i);
            [actions{end + 1}, ~] = temp.placeStructure(player, Structure.road, j);
            log = [log; Action(Type.buildHouse, i) Action(Type.buildRoad, j)];
        end
    end
end

end