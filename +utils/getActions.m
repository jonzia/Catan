function [actions, log] = getActions(board, player)

% -------------------------------------------------------------------------
% This function determines possible future boards given the current board
% and the current player. These potential boards are termed actions and are
% determined by answering the following questions:
% A     Can the player build a house on any node?
% B     Can the player convert a house to a city?
% C     Can the player build a road on any edge?
% D     Can the player play a chance card?
% E     Can the player trade a resource with the bank?
% F     Can the player conduct a trade with another player?
% G     Do nothing, next turn
%
% The actions are returned along with a log of action types.
% -------------------------------------------------------------------------

% Set placeholder for return values
actions = {}; log = {};

% Set placeholder for resources
resources = [Resource.brick Resource.sheep Resource.stone Resource.wheat Resource.wood];

% -------------------------------------------------------------------------
% A (Building Houses)
% -------------------------------------------------------------------------

% For each node...
for i = 1:length(board.nodes)
    % Can the player build a house on this node?
    [~, isValid] = board.placeStructure(player, Structure.house, i);
    % If so, add the resulting board to the action placeholder
    if isValid; [actions{end + 1}, ~] = board.placeStructure(player, Structure.house, i); end
    % Add an entry to the log
    if isValid; log{end + 1} = Action(Type.buildHouse, i); end
end

% -------------------------------------------------------------------------
% B (Building Cities)
% -------------------------------------------------------------------------

% For each node...
for i = 1:length(board.nodes)
    % Can the player build a city on this node?
    [~, isValid] = board.placeStructure(player, Structure.city, i);
    % If so, add the resulting board to the action placeholder
    if isValid; [actions{end + 1}, ~] = board.placeStructure(player, Structure.city, i); end
    % Add an entry to the log
    if isValid; log{end + 1} = Action(Type.buildCity, i); end
end

% -------------------------------------------------------------------------
% C (Building Roads)
% -------------------------------------------------------------------------

% For each edge...
for i = 1:length(board.edges)
    % Can the player build a road on this node?
    [~, isValid] = board.placeStructure(player, Structure.road, i);
    % If so, add the resulting board to the action placeholder
    if isValid; [actions{end + 1}, ~] = board.placeStructure(player, Structure.road, i); end
    % Add an entry to the log
    if isValid; log{end + 1} = Action(Type.buildRoad, i); end
end

% -------------------------------------------------------------------------
% D (Chance Cards)
% -------------------------------------------------------------------------

% Card.buildRoad cards
if board.players{player}.cards.buildRoad > 0
    
    % Create a temporary object and give the player the necessary materials
    temp = board;
    temp.players{player}.cards.brick = temp.players{player}.cards.brick + 2;
    temp.players{player}.cards.wood = temp.players{player}.cards.wood + 2;
    
    % First, find indices of valid road placements
    validRoads = [];
    for i = 1:length(board.edges)
        [~, isValid] = temp.placeStructure(player, Structure.road, i);
        if isValid; validRoads = [validRoads i]; end
    end
    
    % For each valid road placement...
    for i = 1:length(validRoads)
        % Create a temporary object placing the first road
        temp_2 = temp; [temp_2, ~] = temp_2.placeStructure(player, Structure.road, validRoads(i));
        % Determine the valid edges upon which to place second road
        validRoads_2 = [];
        for j = 1:length(board.edges)
            [~, isValid] = temp_2.placeStructure(player, Structure.road, j);
            if isValid; validRoads_2 = [validRoads_2 j]; end
        end
        
        % For each pair of valid roads, generate the resulting board...
        for j = 1:length(validRoads_2)
            [actions{end + 1}, ~] = board.useChance(player, Card.buildRoad, [validRoads(i), validRoads_2(j)]);
            % Add an entry to the log
            log{end + 1} = Action(Type.playChance, Card.buildRoad);
        end
        
    end
    
end

% Card.knight cards
if board.players{player}.cards.knight > 0
    
    % Get valid tiles to which to move thief
    for i = 1:19; if board.tiles{i}.hasThief; currentTile = i; break; end; end
    validTiles = 1:19; validTiles(currentTile) = [];
    
    % For each valid tile...
    for i = 1:length(validTiles)
        tile = validTiles(i);
        
        % Get a list of non-self players with nodes bordering the tile
        players = [];
        for j = 1:length(board.nodes)
            if board.nodes{j}.structure ~= Structure.none
                players = [players board.nodes{j}.player];
            end
        end; players(players == player) = []; players = unique(players);
        
        % If there is no player from which to steal, return action
        if isempty(players)
            [actions{end + 1}, ~] = board.useChance(player, Card.knight, tile, 0);
            % Add an entry to the log
            log{end + 1} = Action(Type.playChance, Card.knight);
            continue
        end
        
        % If there are one or more players from which to steal, return
        % stealing from each player as a separate action
        if ~isempty(players)
            for j = 1:length(players)
                [actions{end + 1}, ~] = board.useChance(player, Card.knight, tile, players(j));
                % Add an entry to the log
                log{end + 1} = Action(Type.playChance, Card.knight);
            end
        end
        
    end
    
end

% Card.monopoly cards
if board.players{player}.cards.monopoly > 0
    % Monopolize each resource as a separate action
    for i = 1:length(resources)
        [actions{end + 1}, ~] = board.useChance(player, Card.monopoly, resources(i));
        % Add an entry to the log
        log{end + 1} = Action(Type.playChance, Card.monopoly);
    end
end

% Card.plenty cards
if board.players{player}.cards.plenty > 0
    
    % Return each resource combination as an action
    pair = ones(length(resources)); pair = triu(pair);
    for i = 1:length(resources)
        for j = 1:length(resources)
            if pair(i, j) == 0; continue; end
                [temp, isValid] = board.useChance(player, Card.plenty, [resources(i), resources(j)]);
                if isValid; actions{end + 1} = temp; end
                % Add an entry to the log
                if isValid; log{end + 1} = Action(Type.playChance, Card.plenty); end
        end
    end
    
end

% -------------------------------------------------------------------------
% E (Bank Trade)
% -------------------------------------------------------------------------

% For each resource that may be traded to the bank...
for i = 1:length(resources)
    if board.players{player}.cards.(string(resources(i))) > 3        
        % Trade it to the bank for each remaining resource as an action
        for j = 1:length(resources)
            if j == i; continue; end
            % Make the trade at the minimum possible cost
            [temp, isValid, cost] = board.tradeBank(player, resources(i), resources(j));
            if isValid; actions{end + 1} = temp; end
            % Add an entry to the log
            if isValid; log{end + 1} = Action(Type.tradeBank, {resources(i) resources(j), cost}); end
        end
        
    end
end

% Purchase a chance card, if possible
[temp, isValid] = board.tradeBank(player, Resource.all, Card.chance);
if isValid; actions{end + 1} = temp;
    log{end + 1} = Action(Type.tradeBank, {Resource.all Card.chance 1});
end

% -------------------------------------------------------------------------
% F (Player Trade)
% -------------------------------------------------------------------------

% For simplicity, the player is only able to trade single resource cards
% for other single resource cards

% For each resource the player has...
for i = 1:length(resources)
    if board.players{player}.cards.(string(resources(i))) > 0
        
        % For each remaining player...
        for j = 1:board.numPlayers
            if j == player; continue; end
            
            % For each remaining resource...
            for k = 1:length(resources)
                if k == i; continue; end
                
                % If the player has the resource, create an action from a
                % trade with that player
                if board.players{j}.cards.(string(resources(k))) > 0
                    [actions{end + 1}, ~] = board.tradePlayer(player, j, ...
                        resources(i), resources(k), 1, 1);
                    % Add an entry to the log
                    log{end + 1} = Action(Type.tradePlayer, {resources(i) resources(k), j});
                end
                
            end
            
        end
        
    end
end

% -------------------------------------------------------------------------
% G (Do-Nothing Action: Next Turn)
% -------------------------------------------------------------------------

actions{end + 1} = board;
% Add an entry to the log
log{end + 1} = Action(Type.pass);

end