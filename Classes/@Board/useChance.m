function [obj, isValid] = useChance(obj, player, card, varargin)

% -------------------------------------------------------------------------
% This function enables a player to use a chance card in their possession.
%
% Arguments (required)
% - player      Int         Player using the chance card
% - card        Card        Chance card being used
%
% Arguments (optional)
% varargin{1}
% - desired     [Resource]  Desired resource(s) (.plenty and .monopoly)
% - edges       [Int]       Edges to place roads (.buildRoad)
% - tile        Int         Destination tile for knight (.knight)
% varargin{2}
% - player      Int         Player from which to steal resource (.knight)
% -------------------------------------------------------------------------

% Ensure proper input arguments are present
if isempty(varargin) && (card == Card.plenty || card == Card.monopoly)
    disp("Error in Board.useChance(): Specify desired resource")
    isValid = false; return
elseif (isempty(varargin) || length(varargin{1}) < 2) && card == Card.buildRoad
    disp("Error in Board.useChance(): Specify edges upon which to place road")
    isValid = false; return
end

% Set validation flag
isValid = false;

% -------------------------------------------------------------------------
% ROAD BUILDING
% -------------------------------------------------------------------------
if card == Card.buildRoad
    
    % Player must have two available roads
    if obj.players{player}.structures.road < 2
        disp("Error in Board.useChance(): Player must have two available roads")
        isValid = false; return
    end
    
    % Give the player the necessary resource cards
    obj.players{player}.cards.brick = obj.players{player}.cards.brick + 2;
    obj.players{player}.cards.wood = obj.players{player}.cards.wood + 2;
    % Determine whether BOTH roads are valid
    [~, isValid] = obj.placeStructure(player, Structure.road, varargin{1}(1));
    if isValid
        [temp, ~] = obj.placeStructure(player, Structure.road, varargin{1}(1));
        [~, isValid] = temp.placeStructure(player, Structure.road, varargin{1}(2));
    end
    % If either is invalid, cancel the transaction; else, place roads
    if ~isValid
        obj.players{player}.cards.brick = obj.players{player}.cards.brick - 2;
        obj.players{player}.cards.wood = obj.players{player}.cards.wood - 2;
        disp("Error in Board.useChance(): Invalid road selection")
        return
    else
        [obj, ~] = obj.placeStructure(player, Structure.road, varargin{1}(1));
        [obj, ~] = obj.placeStructure(player, Structure.road, varargin{1}(2));
        % Trade the card to the bank, if possible
        [obj, isValid] = obj.tradeBank(player, Card.buildRoad, 1);
        if ~isValid; return; end
    end
    
end


% -------------------------------------------------------------------------
% KNIGHT
% -------------------------------------------------------------------------
if card == Card.knight
    
    % Attempt to move the thief
    [obj, isValid] = obj.moveThief(varargin{1}, player, varargin{2});
    if ~isValid; return; end
    
    % Trade the card to the bank, if possible
    [obj, isValid] = obj.tradeBank(player, Card.knight, 1);
    if ~isValid; return; end
    
    % Increment the player's knight counter
    obj.players{player}.knight_cards = obj.players{player}.knight_cards + 1;
    
    % Does this player have more knight cards played than any other player?
    knightFLAG = true;
    for i = 1:obj.numPlayers
        if i == player; continue; end
        if obj.players{i}.knight_cards >= obj.players{player}.knight_cards
            knightFLAG = false;
        end
    end
    
    % If the player has more than 2 knight cards played, and the above is
    % true, award the player the largest army
    if knightFLAG && obj.players{player}.knight_cards > 2
        % Remove card from all players
        for i = 1:obj.numPlayers; obj.players{i}.hasArmyCard = false; end
        % Award to current player
        obj.players{player}.hasArmyCard = true;
    end
    
end


% -------------------------------------------------------------------------
% MONOPOLY
% -------------------------------------------------------------------------
if card == Card.monopoly
    
    % For each player besides the current player...
    for i = 1:obj.numPlayers
        if i == player; continue; end
        
        % If they have any cards of the desired resource...
        if obj.players{i}.cards.(string(varargin{1})) > 0
            % Trade all the cards to the monopolizing player for nothing
            [obj, ~] = obj.tradePlayer(i, player, varargin{1}, varargin{1}, ...
                obj.players{i}.cards.(string(varargin{1})), 0);
        end
        
    end
    
    % Trade the card to the bank, if possible
    [obj, isValid] = obj.tradeBank(player, Card.monopoly, 1);
    if ~isValid; return; end
    
end


% -------------------------------------------------------------------------
% PLENTY
% -------------------------------------------------------------------------
if card == Card.plenty
    
    % varargin{1} may only contain resource cards
    for i = 1:length(varargin{1})
        if varargin{1}(i) ~= Resource.brick && varargin{1}(i) ~= Resource.sheep && ...
                varargin{1}(i) ~= Resource.stone && varargin{1}(i) ~= Resource.wheat && ...
                varargin{1}(i) ~= Resource.wood
            disp("Error in Board.useChance(): Only resource cards may be obtained from bank")
            isValid = false; return
        end
    end
    
    if length(varargin{1}) == 1
        % Take two resources from the bank, if possible
        [obj, isValid] = obj.tradeBank(player, varargin{1}, -2);
        if ~isValid; return; end
    elseif length(varargin{1}) == 2
        % Take one of each resources from the bank, if both possible
        [temp, isValid] = obj.tradeBank(player, varargin{1}(1), -1);
        if ~isValid; return; end
        [temp_2, isValid] = temp.tradeBank(player, varargin{1}(2), -1);
        if ~isValid; return; end
        obj = temp_2;   % Return the object if both are possible
    else
        disp("Error in Board.useChance(): Invalid number of resource cards selected")
        isValid = false; return
    end
    
    % Trade the card to the bank, if possible
    [obj, isValid] = obj.tradeBank(player, Card.plenty, 1);
    if ~isValid; return; end
    
end