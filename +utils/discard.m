function [actions, log] = discard(board, player, varargin)

% -------------------------------------------------------------------------
% This function returns the actions corresponding to the players discarding
% half of their cards.
%
% Arguments (optional)
% - maxCombs    Int     Maximum combinations for discarding
% - thresh      Int     Threshold for number of cards before discarding at
%                       random
% -------------------------------------------------------------------------

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'maxCombs'); maxCombs = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'thresh'); thresh = varargin{arg + 1};
        end
    end
end

% Set defaults for optional arguments
if ~exist('maxCombs', 'var'); maxCombs = 100; end
if ~exist('thresh', 'var'); thresh = 10; end

% Initialize action and log placeholders
actions = {}; log = {};

% Compute number of cards to keep
numCards = board.players{player}.cards.brick + board.players{player}.cards.sheep + ...
    board.players{player}.cards.stone + board.players{player}.cards.wheat + ...
    board.players{player}.cards.wood;
numKeep = round(numCards/2);

% Get the number of each cards
numBrick = board.players{player}.cards.brick; brickCounter = numBrick;
numSheep = board.players{player}.cards.sheep; sheepCounter = numSheep;
numStone = board.players{player}.cards.stone; stoneCounter = numStone;
numWheat = board.players{player}.cards.wheat; wheatCounter = numWheat;
numWood = board.players{player}.cards.wood; woodCounter = numWood;

% Enumerate all cards
allCards = [];
for i = 1:numCards
    if brickCounter > 0; allCards = [allCards Card.brick]; brickCounter = brickCounter - 1; end
    if sheepCounter > 0; allCards = [allCards Card.sheep]; sheepCounter = sheepCounter - 1; end
    if stoneCounter > 0; allCards = [allCards Card.stone]; stoneCounter = stoneCounter - 1; end
    if wheatCounter > 0; allCards = [allCards Card.wheat]; wheatCounter = wheatCounter - 1; end
    if woodCounter > 0; allCards = [allCards Card.wood]; woodCounter = woodCounter - 1; end
end; cardNum = 1:numCards;

% If the number of cards is less than 10, return
if numCards < 10; return; end

% Limit the card number (for memory purposes)
if numCards >= thresh
    % Select cards to delete at random
    delIdx = 1:numCards; delIdx = delIdx(randperm(length(delIdx)));
    delIdx = delIdx(1:(numCards - numKeep));
    for i = 1:length(delIdx)
        switch allCards(delIdx(i))
            case Card.brick; [board, ~] = board.tradeBank(player, Resource.brick, 1);
            case Card.sheep; [board, ~] = board.tradeBank(player, Resource.sheep, 1);
            case Card.stone; [board, ~] = board.tradeBank(player, Resource.stone, 1);
            case Card.wheat; [board, ~] = board.tradeBank(player, Resource.wheat, 1);
            case Card.wood; [board, ~] = board.tradeBank(player, Resource.wood, 1);
        end; actions{end + 1} = board; log{end + 1} = Action(Type.discard, numCards - numKeep);
    end; return
end

% Get all possible sub-combinations of cards
combs = nchoosek(cardNum, numKeep);

% If the maximum number of combinations has been set...
if ~isinf(maxCombs)
    % Select the specified number of rows at random
    rows = 1:size(combs, 1); rows = rows(randperm(length(rows)));
    rows = rows(1:maxCombs);
else
    % Else, select all rows
    rows = 1:size(combs, 1);
end

% For each combination...
for i = rows
    
    % Get the count of each card
    numBrick_2 = 0; numSheep_2 = 0; numStone_2 = 0; numWheat_2 = 0; numWood_2 = 0;
    
    % For each card...
    for j = 1:length(combs(i, :))
        % Increment the correct counter
        switch allCards(combs(i, j))
            case Card.brick; numBrick_2 = numBrick_2 + 1;
            case Card.sheep; numSheep_2 = numSheep_2 + 1;
            case Card.stone; numStone_2 = numStone_2 + 1;
            case Card.wheat; numWheat_2 = numWheat_2 + 1;
            case Card.wood; numWood_2 = numWood_2 + 1;
        end
    end
    
    % Create a temporary object with these exchanges
    if numBrick - numBrick_2 > 0; [temp, ~] = board.tradeBank(player, Resource.brick, numBrick - numBrick_2); end
    if numSheep - numSheep_2 > 0; [temp, ~] = board.tradeBank(player, Resource.sheep, numSheep - numSheep_2); end
    if numStone - numStone_2 > 0; [temp, ~] = board.tradeBank(player, Resource.stone, numStone - numStone_2); end
    if numWheat - numWheat_2 > 0; [temp, ~] = board.tradeBank(player, Resource.wheat, numWheat - numWheat_2); end
    if numWood - numWood_2 > 0; [temp, ~] = board.tradeBank(player, Resource.wood, numWood - numWood_2); end
    
    % Return the updated board as an action and log the action
    actions{end + 1} = temp; log{end + 1} = Action(Type.discard, numCards - numKeep);
    
end

end