function [obj, isValid] = moveThief(obj, destination, byPlayer, toPlayer)

% -------------------------------------------------------------------------
% This function moves the thief for a player and steals a resource.
%
% Arguments (required):
% - destination     Int     Destination tile to move thief
% - byPlayer        Int     Player moving thief
% - toPlayer        Int     Player from which to steal (0 if none available)
% -------------------------------------------------------------------------

% Player may not steal from themselves
if byPlayer == toPlayer
    disp("Error in Board.moveThief(): Player may not steal from themselves")
    isValid = false; return
end

% Set validity flag
isValid = true;

% Move the thief to a NEW tile
if ~obj.tiles{destination}.hasThief
    % Remove thief from old tile
    for i = 1:length(obj.tiles)
        if obj.tiles{i}.hasThief; obj.tiles{i}.hasThief = false; break; end
    end
    % Add thief to new tile
    obj.tiles{destination}.hasThief = true;
else
    % If the choice was invalid, return an error
    disp("Error in Board.moveThief(): Thief must be moved to new tile")
    isValid = false; return
end

if toPlayer > 0

    % Selected player must have a structure on a node adjacent to the tile
    hasStructure = false;
    for i = 1:length(obj.nodes)
        if any(ismember(obj.nodes{i}.tiles, destination)) && ...
                obj.nodes{i}.structure ~= Structure.none && ...
                obj.nodes{i}.player == toPlayer
            hasStructure = true;
        end
    end; if ~hasStructure; isValid = false; disp("Error in Board.moveThief(): Invalid player selected"); ...
            return; end

    % Determine all resource cards held by player
    cards = [obj.players{toPlayer}.cards.brick obj.players{toPlayer}.cards.sheep ...
        obj.players{toPlayer}.cards.stone obj.players{toPlayer}.cards.wheat ...
        obj.players{toPlayer}.cards.wood];
    if sum(cards) == 0; return; end     % Return if no cards to steal

    % Select a card at random to steal
    idx = find(cards > 0); idx = idx(randi([1, length(idx)]));

    % Steal card from player
    switch idx
        case 1
            [obj, ~] = obj.tradePlayer(toPlayer, byPlayer, Resource.brick, Resource.brick, 1, 0);
        case 2
            [obj, ~] = obj.tradePlayer(toPlayer, byPlayer, Resource.sheep, Resource.sheep, 1, 0);
        case 3
            [obj, ~] = obj.tradePlayer(toPlayer, byPlayer, Resource.stone, Resource.stone, 1, 0);
        case 4
            [obj, ~] = obj.tradePlayer(toPlayer, byPlayer, Resource.wheat, Resource.wheat, 1, 0);
        case 5
            [obj, ~] = obj.tradePlayer(toPlayer, byPlayer, Resource.wood, Resource.wood, 1, 0);
    end

end

end