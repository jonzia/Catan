function [obj, isValid, varargout] = tradeBank(obj, player, fromResource, varargin)

% -------------------------------------------------------------------------
% This function conducts a trade between a player in the bank. The trade
% may either be a 4:1 trade, a 3:1/2:1 trade if the player has a valid
% harbor, or a trade while placing a structure. The bank automatically
% computes the minimum cost to the player for resource trades, and approves
% resource payments from the player when purchasing structures. The player
% may also buy a chance card.
%
% Arguments:
% - fromPlayer      Int         Player from which trade is originating
% - fromResource    Resource    Resource to be traded to bank (or
%                               toResource in the case of transaction < 0)
%                               (put Resource.all when buying structure)
%
% Arguments (optional):
% (varargin{1})
% - toResource      Resource    Resource to be obtained from bank
% ~~~ OR ~~~
% - forStructure    Structure   Structure being purchased by player
% ~~~ OR ~~~
% - forCard         Card        Chance card (Card.chance only)
% ~~~ OR ~~~
% transaction       Int         >0: Give cards to bank
%                               <0: Take cards from bank
%
% Outputs
% varargout{1} = obj
% varargout{2} = isValid
% varargout{3} = cost
% -------------------------------------------------------------------------

% Parse optional input arguments
if ~isempty(varargin)
    if isa(varargin{1}, 'Structure')
        forStructure = varargin{1}; toResource = Resource.none; card = Card.none; transaction = [];
    elseif isa(varargin{1}, 'Resource')
        toResource = varargin{1}; forStructure = Structure.none; card = Card.none; transaction = [];
    elseif isa(varargin{1}, 'Card') && varargin{1} == Card.chance
        toResource = Resource.none; forStructure = Structure.none; card = Card.chance; transaction = [];
    elseif isa(varargin{1}, 'Card') && varargin{1} ~= Card.chance
        disp("Error in Board.tradeBank(): Only chance cards may be traded with the bank")
        isValid = false; return
    else
        toResource = Resource.none; forStructure = Structure.none; card = Card.none;
        transaction = varargin{1};
    end
else
    disp("Error in Board.tradeBank(): The item type being purchased must be provided");
    isValid = false; return
end

% Set validity flag for the deal
isValid = true;


% -------------------------------------------------------------------------
% TRANSACTION
% -------------------------------------------------------------------------
if ~isempty(transaction)
    
    % If the length of fromResource and transaction aren't the same length,
    % throw an error
    if length(transaction) ~= length(fromResource)
        disp("Error in Board.tradeBank(): A transaction amount must be provided for each transaction")
        isValid = false; return
    end
    
    % Determine whether all transactions may be made
    for i = 1:length(fromResource)
        
        % If the player is depositing cards...
        if transaction(i) > 0
            % Determine whether the player has enough cards to meet the transaction
            if obj.players{player}.cards.(string(fromResource(i))) < transaction(i)
                isValid = false; return     % Return before any transactions are made
            end
            % If the player is withdrawing cards...
        elseif transaction(i) < 0
            % Determine whether the bank has enough cards to meet the transaction
            if obj.bank.(string(fromResource(i))) < abs(transaction(i))
                isValid = false; return     % Return before any transactions are made
            end
        end
        
    end
    
    % If all transactions can be made, make them
    for i = 1:length(fromResource)
        
        % If the player is depositing cards...
        if transaction(i) > 0
            
            obj.players{player}.cards.(string(fromResource(i))) = ...
                obj.players{player}.cards.(string(fromResource(i))) - transaction(i);
            obj.bank.(string(fromResource(i))) = ...
                obj.bank.(string(fromResource(i))) + transaction(i);
            
            % If the player is withdrawing cards...
        elseif transaction(i) < 0
            
            obj.players{player}.cards.(string(fromResource(i))) = ...
                obj.players{player}.cards.(string(fromResource(i))) + abs(transaction(i));
            obj.bank.(string(fromResource(i))) = ...
                obj.bank.(string(fromResource(i))) - abs(transaction(i));
            
        end
        
    end
    
end


% -------------------------------------------------------------------------
% RESOURCE CARD PURCHASING
% -------------------------------------------------------------------------
if toResource ~= Resource.none
    
    % Determine the minimum price for the player, given the resource being
    % offered in exchange
    
    % Set the default cost
    cost = 4;
    
    % For each node in the graph...
    for i = 1:length(obj.nodes)
        % If the node contains a structure owned by the player and has an
        % associated harbor with the appropriate resource, get the cost
        if obj.nodes{i}.structure ~= Structure.none && ...
                obj.nodes{i}.player == player && ~isempty(obj.nodes{i}.harbor)
                if obj.nodes{i}.harbor.resource == fromResource || obj.nodes{i}.harbor.resource == Resource.all
                    cost = obj.nodes{i}.harbor.cost;
                end
        end   
    end
    
    % Set output arguments
    if nargout > 2; varargout{1} = cost; end
    
    % If the deal is valid, conduct it at the minimum cost
    [obj, isValid] = obj.tradeBank(player, [fromResource, toResource], [cost, -1]);
    if ~isValid; return; end
    
end


% -------------------------------------------------------------------------
% CHANCE CARD PURCHASING
% -------------------------------------------------------------------------
if card ~= Card.none
    
    % Determine whether the bank has enough of the desired resource
    chanceCards = [obj.bank.buildRoad obj.bank.knight obj.bank.monopoly ...
        obj.bank.plenty obj.bank.victoryPoint];
    if sum(chanceCards) == 0; isValid = false; return; end

    % Get the nonzero indices of chanceCards and select a random index
    idx = find(chanceCards > 0); idx = idx(randi([1, length(idx)]));
    
    % If the deal is valid, conduct it
    [obj, isValid] = obj.tradeBank(player, [Resource.sheep, Resource.wheat, ...
        Resource.stone], [1, 1, 1]); if ~isValid; return; end
    switch idx
        case 1; [obj, ~] = obj.tradeBank(player, Card.buildRoad, -1);
        case 2; [obj, ~] = obj.tradeBank(player, Card.knight, -1);
        case 3; [obj, ~] = obj.tradeBank(player, Card.monopoly, -1);
        case 4; [obj, ~] = obj.tradeBank(player, Card.plenty, -1);
        case 5; [obj, ~] = obj.tradeBank(player, Card.victoryPoint, -1);
    end
    
end


% -------------------------------------------------------------------------
% STRUCTURE BUILDING PAYMENTS
% -------------------------------------------------------------------------
if forStructure ~= Structure.none
    
    % Withdraw a certain resource from the player if it's available
    switch forStructure
        % If the player is building a house...
        case Structure.house
            [obj, isValid] = obj.tradeBank(player, [Resource.brick, Resource.sheep, ...
                Resource.wheat, Resource.wood], [1, 1, 1, 1]); if ~isValid; return; end
            % If the player is building a city...
        case Structure.city
            [obj, isValid] = obj.tradeBank(player, [Resource.stone, Resource.wheat], ...
                [3, 2]); if ~isValid; return; end
            % If the player is building a road...
        case Structure.road
            [obj, isValid] = obj.tradeBank(player, [Resource.brick, Resource.wood], ...
                [1, 1]); if ~isValid; return; end
    end

end

end