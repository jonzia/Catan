function obj = computeVP(obj, player)

% -------------------------------------------------------------------------
% This function computes the victry points earned by a player.
% -------------------------------------------------------------------------

% Public and private VP counters
VP_public = 0; VP_private = 0;

% For each node...
for i = 1:length(obj.nodes)
    
    % If the node has a house belonging to the player, add a point
    if obj.nodes{i}.structure == Structure.house && obj.nodes{i}.player == player
        VP_public = VP_public + 1; VP_private = VP_private + 1;
    end
    
    % If the node has a city belonging to the player, add two points
    if obj.nodes{i}.structure == Structure.city && obj.nodes{i}.player == player
        VP_public = VP_public + 2; VP_private = VP_private + 2;
    end
    
    % Does the player have the largest army card? If so, add two points
    if obj.players{player}.hasArmyCard; ...
            VP_public = VP_public + 2; VP_private = VP_private + 2; end
    
end
    
% Does the player have the longest road? If so, add two points
hasLongestRoad = true;
for i = 1:obj.numPlayers
    if obj.players{i}.road_length >= obj.players{player}.road_length
        hasLongestRoad = false;
    end
end; if hasLongestRoad; VP_private = VP_private + 2; VP_public = VP_public + 2; end
    
% Does the player have victory point cards? If so, add a secret point
VP_private = VP_private + obj.players{player}.cards.victoryPoint;

% Assign output values
obj.players{player}.VP_public = VP_public;
obj.players{player}.VP_private = VP_private;
    
end

end