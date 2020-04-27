function [obj, isValid] = placeStructure(obj, player, structure, position)

% -------------------------------------------------------------------------
% This function places a structure for a player on a node or edge.
%
% Arguments:
% - player      Int         Index of player placing structure
% - structure   Structure   House, city, or road structure
% - position    Int         Node or edge number to place resource
% -------------------------------------------------------------------------

% Set validity flag
isValid = true;


% -------------------------------------------------------------------------
% BUILDING A HOUSE
% -------------------------------------------------------------------------
if structure == Structure.house
    
    % Determine whether the node is free of other houses
    if obj.nodes{position}.structure ~= Structure.none
        isValid = false; return
    end
    
    % Determine whether there is a connecting road adjacent to the node
    % If this is one of the player's first two houses, ignore
    houseCount = 0;
    for i = 1:length(obj.nodes)
        if obj.nodes{i}.structure ~= Structure.none && obj.nodes{i}.player == player
            houseCount = houseCount + 1;
        end
    end
    if houseCount > 1
        % For each edge in the graph...
        roadFLAG = false;
        for i = 1:length(obj.edges)
            if any(ismember(obj.edges{i}.nodePair, position)) && ...
                    obj.edges{i}.structure == Structure.road && ...
                    obj.edges{i}.player == player
                roadFLAG = true;    % Does there exist a valid road?
            end
        end; if ~roadFLAG; isValid = false; return; end	% If not, return
    end
    
    % Determine whether there are other houses on adjacent nodes
    % First, determine indices of adjacent nodes
    idx = find(obj.adjacency(position, :) > 0);
    for i = 1:length(idx)	% For each adjacent node...
        if obj.nodes{idx(i)}.structure ~= Structure.none
            % If it has a structure, return false
            isValid = false; return
        end
    end
    
    % Determine whether the player has houses available
    if obj.players{player}.structures.house == 0
        isValid = false; return
    end
    
    % If the transaction is valid, place the house
    [obj, isValid] = obj.tradeBank(player, Resource.all, Structure.house);
    if ~isValid; return; end
    obj.nodes{position}.structure = Structure.house;
    obj.nodes{position}.player = player;
    obj.players{player}.structures.house = obj.players{player}.structures.house - 1;
    
end


% -------------------------------------------------------------------------
% BUILDING A CITY
% -------------------------------------------------------------------------
if structure == Structure.city
    
    % The node must have a house owned by the player
    if obj.nodes{position}.structure ~= Structure.house || ...
            obj.nodes{position}.player ~= player
        isValid = false; return
    end
    
    % Determine whether the player has cities available
    if obj.players{player}.structures.city == 0
        isValid = false; return
    end
    
    % If the transaction is valid, place the city
    [obj, isValid] = obj.tradeBank(player, Resource.all, Structure.city);
    if ~isValid; return; end
    obj.nodes{position}.structure = Structure.city;
    obj.players{player}.structures.city = obj.players{player}.structures.city - 1;
    obj.players{player}.structures.house = obj.players{player}.structures.house + 1;
    
end


% -------------------------------------------------------------------------
% BUILDING A ROAD
% -------------------------------------------------------------------------
if structure == Structure.road
    
    % The edge must not already contain a structure
    if obj.edges{position}.structure ~= Structure.none
        isValid = false; return
    end
    
    % An adjacent node must have a structure owned by the player...
    adjNode = false;
    if (obj.nodes{obj.edges{position}.nodePair(1)}.structure ~= Structure.none && ...
            obj.nodes{obj.edges{position}.nodePair(1)}.player == player) || ...
            (obj.nodes{obj.edges{position}.nodePair(2)}.structure ~= Structure.none && ...
            obj.nodes{obj.edges{position}.nodePair(2)}.player == player)
        adjNode = true;
    end
    
    % OR an adjacent edge must have a road owned by the player
    adjEdge = false;
    for i = 1:length(obj.edges)
        if i == position; continue; end
        if (any(ismember(obj.edges{position}.nodePair, obj.edges{i}.nodePair(1))) || ...
                any(ismember(obj.edges{position}.nodePair, obj.edges{i}.nodePair(2)))) && ...
                obj.edges{i}.structure ~= Structure.none && obj.edges{i}.player == player
            adjEdge = true; break
        end
    end
    
    % If either condition is met, continue
    if ~adjNode && ~adjEdge; isValid = false; return; end
    
    % Determine whether the player has roads available
    if obj.players{player}.structures.road == 0
        isValid = false; return
    end
    
    % If the transaction is valid, place the road
    [obj, isValid] = obj.tradeBank(player, Resource.all, Structure.road);
    if ~isValid; return; end
    obj.edges{position}.structure = Structure.road;
    obj.edges{position}.player = player;
    obj.players{player}.structures.road = obj.players{player}.structures.road - 1;
    
    % Add a connection to the player's road adjacency matrix
    obj.players{player}.adjacency(obj.edges{position}.nodePair(1), obj.edges{position}.nodePair(2)) = 1;
    obj.players{player}.adjacency(obj.edges{position}.nodePair(2), obj.edges{position}.nodePair(1)) = 1;
    
    % Determine the length of  the character's longest road
    G = digraph(obj.players{player}.adjacency);
    D = distances(G); D(isinf(D)) = 0;
    obj.players{player}.road_length = max(D(:));
    
end

end