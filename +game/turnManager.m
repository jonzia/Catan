function board = turnManager(board, turn, computer, model, varargin)

% -------------------------------------------------------------------------
% This function manages a single turn of the game, based on the current
% player, which player is the computer, and the trained model.
%
% Arguments (required)
% - board       Board   Board object
% - turn        Int     Current turn
% - computer    Int     Computer player
% - model       Model   Trained quality function
%
% Arguments (optional)
% - roll        Bool    If true, players enter dice roll manually
% - maxActions  Int     Maximum number of actions by computer
% - figure              Figure handle
% -------------------------------------------------------------------------

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'roll'); roll = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'maxActions'); maxActions = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'figure'); f = varargin{arg + 1};
        end
    end
end

% Set defaults for optional arguments
if ~exist('roll', 'var'); roll = false; end
if ~exist('maxActions', 'var'); maxActions = inf; end
if ~exist('f', 'var'); f = []; end

% Get the number of players
numPlayers = board.numPlayers; initFLAG = false;

% Get the current player
if turn <= 2*numPlayers
    % Get the player for initial house/road placement
    order = [1:numPlayers, numPlayers:-1:1]; player = order(turn);
    initFLAG = true;
else
    % Otherwise, first adjust the turn counter...
    turn = turn - (2*numPlayers);
    % ... then get the current player
    player = mod(turn, numPlayers); if player == 0; player = numPlayers; end
end

% Display the current player
disp("***** Player " + string(player) + " *****");

% -------------------------------------------------------------------------
% Placing Initial Houses / Roads
% -------------------------------------------------------------------------

% If the turn counter is less than 2x the number of players, set initial
% houses and roads
if turn <= 2*numPlayers && initFLAG
    
    % Is the current player the computer?
    if computer == player
        
        % If so, the computer selects the node and edge on which to place
        % the initial house and road. First, get the available actions.
        [actions, log] = board.initialHouse(player);
        % Then rank the actions using the quality function
        rank = utils.rankActions(actions, model, player);
        % Select the optimal action
        board = actions{rank(1)};
        
        % Notify the players
        entry = log(rank(1), 1); entry.getDescription(player);
        entry = log(rank(1), 2); entry.getDescription(player);
        
    else
        
        % Otherwise, prompt the user to select where they would like to
        % place the house, followed by the road
        disp("Player " + string(player) + ": Please select a location for your settlement.")
        
        % Get player's input from the current figure
        [x, y] = ginput(1);
        % Find the nearest node to the player's selection
        node = utils.findClosestNode(board, [x, y]);
        
        % Give the user the necessary resources to place the house and road
        board = board.tradeBank(player, Resource.brick, -2);
        board = board.tradeBank(player, Resource.sheep, -1);
        board = board.tradeBank(player, Resource.wheat, -1);
        board = board.tradeBank(player, Resource.wood, -2);
        
        % Attempt to place the house on the desired node
        [board, valid] = board.placeStructure(player, Structure.house, node);
        
        % If invalid, repeat until valid
        while ~valid
            % Display error message
            disp("Invalid selection. Please try again.")
            % Accept player's input from the current figure
            [x, y] = ginput(1); node = utils.findClosestNode(board, [x, y]);
            % Attempt to place the house on the desired node
            [board, valid] = board.placeStructure(player, Structure.house, node);
        end
        
        % Prompt the user to select a place to put the road
        disp("Player " + string(player) + ": Please select a location for your road.")
        
        % Get player's input from the current figure and find the closest edge
        [x, y] = ginput(1); edge = utils.findClosestEdge(board, [x, y]);
        
        % Attempt to place the road on the desired edge
        [board, valid] = board.placeStructure(player, Structure.road, edge);
        
        % If invalid, repeat until valid
        while ~valid
            % Display error message
            disp("Invalid selection. Please try again.")
            % Accept player's input from the current figure
            [x, y] = ginput(1); edge = utils.findClosestEdge(board, [x, y]);
            % Attempt to place the house on the desired node
            [board, valid] = board.placeStructure(player, Structure.road, edge);
        end
        
    end
    
    % Return when complete
    if ~isempty(f); board.plotBoard(f); else; board.plotBoard(); end; return
    
end

% -------------------------------------------------------------------------
% Subsequent Turns
% -------------------------------------------------------------------------

% On the first turn, distribute initial resources
if turn == 1
    
    % Display prompt
    disp("Distributing initial resources...")
    
    % Distribute resources
    for i = 1:12; board.dice = i; if i ~= 7; board = board.distribute(); end; end
    
end

% If it is the computer's turn...
if player == computer
    
    % Roll the dice and display the result (if necessary)
    if ~roll; board = board.roll(); else; board.dice = input("Please enter dice roll: "); end
    disp("Computer rolls: " + string(board.dice));
    
    % Distribute resources and print cards
    board = board.distribute(); disp("Distributing resources..."); printResources();
    
    % If the computer rolls a 7...
    if board.dice == 7
        
        % The computer discards if they have to. First, get
        % possible discard actions.
        [actions, log] = utils.discard(board, player);
        % If the player does not need to discard, continue
        if ~isempty(actions)
            % Else, select the optimal discard action
            rank = utils.rankActions(actions, model, player);
            board = actions{rank(1)}; numDisc = log{rank(1)}.metadata;
            % Report the number discarded by the computer
            log{rank(1)}.getDescription(player);
        end
        
        % Once discarding is complete, the computer moves the thief
        [actions, log] = utils.rollSeven(board, player);
        % Select the optimal action
        rank = utils.rankActions(actions, model, player);
        board = actions{rank(1)};
        % Report the action
        log{rank(1)}.getDescription(player);
        
    end
    
    % Enforce action counter and end turn on pass action
    turnFLAG = true; counter = 0;
    
    % Create a placeholder for prohibited trades this turn
    prohibited = {};
    
    while turnFLAG
        
        % Determine possible actions
        [actions, log] = utils.getActions(board, player);
        
        % Evaluate actions, and choose optimal action
        rank = utils.rankActions(actions, model, player);
            
        % Set placeholders for selecting non-prohibited action
        prohibFLAG = true; c = 1;
        % If the log does not contain this action, proceed
        while prohibFLAG
            % Get the optimal index
            idx = rank(c);
            % If the log does not contain this action, proceed
            if ~utils.logContains(prohibited, log{idx}); prohibFLAG = false;
            else; c = c + 1;
            end
        end
        
        % If the action is not a trade with a player, proceed
        if log{idx}.actionType ~= Type.tradePlayer
            board = actions{idx}; log{idx}.getDescription(player);
        else
            
            % Else, notify the player that the computer has offered them a
            % deal. Ask whether they accept the deal.
            response = input("The computer has offered to give Player " + ...
                string(log{idx}.metadata{3}) + " a " + string(log{idx}.metadata{1}) + ...
                " in exchange for a " + string(log{idx}.metadata{2}) + ...
                ". Do you accept? (y/n): ", 's');
            
            % If they find the trade favorable, proceed
            if strcmp(response, "y")
                board = actions{idx}; log{idx}.getDescription(player);
            else
                % Otherwise, add the move to the prohibited list
                prohibited{end + 1} = log{idx};
            end
            
        end
        
        % Increment the turn counter
        counter = counter + 1;
        
        % If the action type is "pass" end the turn
        if log{idx}.actionType == Type.pass; turnFLAG = false;
            % Else, if the turn counter has been exceeded, end the turn
        elseif counter >= maxActions; turnFLAG = false;
        end
        
    end
    
else
    
    % Otherwise, it is the player's turn
    
    % Roll the dice and display the result (if necessary)
    if ~roll; board = board.roll(); else; board.dice = input("Please enter dice roll: "); end
    disp("Player " + string(player) + " rolls: " + string(board.dice));
    
    % Distribute resources and print cards
    board = board.distribute(); disp("Distributing resources..."); printResources();
    
    % If the player rolls a 7...
    if board.dice == 7
        
        % Discarding
        % Get the total number of cards
        totalCards = board.players{player}.cards.brick + board.players{player}.cards.sheep + ...
            board.players{player}.cards.stone + board.players{player}.cards.wheat + ...
            board.players{player}.cards.wood;
        % If the total cards is greater than 10...
        if totalCards > 10
            
            % Determine number to discard
            numDisc = round(totalCards/2);
            
            % For each card to discard...
            for i = 1:numDisc
                % Set validity flag
                valid = false;
                % Until a valid choice is made...
                while ~valid
                    % Ask the user which resource to discard
                    x = input("Which Resource would you like to discard? (" + ...
                        string(i) + " of " + string(numDisc) + ") ");
                    % If it's possible to discard the resource...
                    if board.players{player}.cards.(string(x)) > 0
                        % ... discard the card
                        [board, ~] = board.tradeBank(player, x, 1); valid = true;
                    else
                        disp("Error: Invlid card selected.")
                    end
                end
            end
            
        end
        
        % Prompt the user where they would like to move the
        % thief, and from whom they would like to steal
        disp("Please select the tile to which you would like to move the thief.")
        [x, y] = ginput(1); tile = utils.findClosestTile(board, [x, y]);
        victim = input("From which player would you like to steal? ");

        % Attempt to move the thief
        [board, valid] = board.moveThief(tile, player, victim);

        % Return sucess/failure
        if ~valid; disp("Error: Invalid move. Move not recorded.");
        else; disp("Successfully moved thief.")
        end
        
        % Refresh the board and print resources
        if ~isempty(f); board.plotBoard(f); else; board.plotBoard(); end; printResources();
        
    end
    
    % Initialize flag for continuing turn
    FLAG = true;
    
    while FLAG
    
        % Prompt the user for what type of action they would like to perform
        response = input("What action would you like to perform?: ");

        % Determine the next steps depending on action type
        switch response

            case Type.buildHouse

                % Prompt the user to select a node
                disp("Please select a node on which to build.")
                % Get player's input from the current figure
                [x, y] = ginput(1); node = utils.findClosestNode(board, [x, y]);
                % Attempt to place the house on the desired node
                [board, valid] = board.placeStructure(player, Structure.house, node);
                % Return success/failure
                if ~valid; disp("Error: Invalid move. Move not recorded.")
                else; disp("Settlement successfully placed on Node " + string(node))
                end

            case Type.buildCity
                
                % Prompt the user to select a node
                disp("Please select a node on which to build.")
                % Get player's input from the current figure
                [x, y] = ginput(1); node = utils.findClosestNode(board, [x, y]);
                % Attempt to place the house on the desired node
                [board, valid] = board.placeStructure(player, Structure.city, node);
                % Return success/failure
                if ~valid; disp("Error: Invalid move. Move not recorded.")
                else; disp("City successfully placed on Node " + string(node))
                end

            case Type.buildRoad
                
                % Prompt the user to select an edge
                disp("Please select an edge on which to build.")
                % Get player's input from the current figure
                [x, y] = ginput(1); edge = utils.findClosestEdge(board, [x, y]);
                % Attempt to place the house on the desired node
                [board, valid] = board.placeStructure(player, Structure.road, edge);
                % Return success/failure
                if ~valid; disp("Error: Invalid move. Move not recorded.")
                else; disp("Road successfully placed on Edge " + string(edge))
                end

            case Type.playChance
                
                % Prompt the user to enter which card they would like to play
                card = input("Which card would you like to play? ");
                
                % Determine next steps depending on card type
                switch card
                    
                    case Card.buildRoad
                        
                        % Set edge placeholder
                        edges = [0 0];
                        
                        for i = 1:2
                            % Ask the user where they would like to place the road
                            disp("Please select location of road " + string(i) + ".")
                            [x, y] = ginput(1); edges(i) = utils.findClosestEdge(board, [x, y]);
                        end

                        % Attempt to play the card
                        [board, valid] = board.useChance(player, card, edges);

                        % Return sucess/failure
                        if ~valid; disp("Error: Invalid move. Move not recorded.");
                        else; disp("Roads sucessfully placed.")
                        end
                        
                    case Card.monopoly
                        
                        % Ask the user which resource they would like to
                        % monopolize from the other players
                        x = input("Which Resource would you like to monopolize? ");

                        % Attempt to monopolize the resource
                        [board, valid] = board.useChance(player, card, x);

                        % Return sucess/failure
                        if ~valid; disp("Error: Invalid move. Move not recorded.");
                        else; disp("Resource successfully monopolized.")
                        end
                        
                    case Card.plenty
                        
                        % Set resource placeholder
                        resources = [Resource.all, Resource.all];
                        
                        % Prompt the user for desired resources
                        resources(1) = input("What is the first Resource you would like? ");
                        resources(2) = input("What is the second Resource you would like? ");
                        
                        % Attempt to play the card
                        [board, valid] = board.useChance(player, card, resources);
                        
                        % Return sucess/failure
                        if ~valid; disp("Error: Invalid move. Move not recorded.");
                        else; disp("Resources successfully obtained.")
                        end
                        
                    case Card.knight
                        
                        % Prompt the user where they would like to move the
                        % thief, and from whom they would like to steal
                        disp("Please select the tile to which you would like to move the thief.")
                        [x, y] = ginput(1); tile = utils.findClosestTile(board, [x, y]);
                        victim = input("From which player would you like to steal? ");
                        
                        % Attempt to play the card
                        [board, valid] = board.useChance(player, card, {tile, victim});
                        
                        % Return sucess/failure
                        if ~valid; disp("Error: Invalid move. Move not recorded.");
                        else; disp("Knight successfully played.")
                        end
                        
                end

            case Type.tradeBank
                
                % Prompt the user to specify whether they would like to
                % trade for a resource or chance card
                x = input("Please enter the desired Resource, or Card.chance: ");
                
                % If the input is a resource, ask the user what they would
                % like to trade
                if isa(x, 'Resource')
                    y = input("What Resource would you like to trade? ");
                    % Attempt to conduct the trade
                    [board, valid] = board.tradeBank(player, y, x);
                    % Return success/failure
                    if ~valid; disp("Invalid trade. Move not recorded.")
                    else; disp("Trade successfully recorded.")
                    end
                else
                    % If the input is a chance card, deal a chance card
                    [board, valid] = board.tradeBank(player, Resource.all, x);
                    % Return success/failure
                    if ~valid; disp("Invalid trade. Move not recorded.")
                    else; disp("Resource card obtained successfully.")
                    end
                end

            case Type.tradePlayer
                
                % First, ask the player with whom they would like to trade
                x = input("With which player would you like to trade? ");
                toTrade = input("Which Resource would you like to give? "); toNum = input("How many? ");
                fromTrade = input("Which Resource would you like to receive? "); fromNum = input("How many? ");
                
                % If the player would like to trade with the computer...
                if x == computer
                    
                    % Create the trade in a simulation
                    [trade, valid] = board.tradePlayer(player, x, toTrade, fromTrade, toNum, fromNum);
                    
                    if valid
                    
                        % Determine whether the computer likes the board as is,
                        % or prefers the updated board.
                        rank = utils.rankActions({board, trade}, model, x);

                        % If the computer approves, conduct the trade
                        if rank(1) == 2
                            board = trade; disp("Trade accepted.")
                        else
                            % Else, return the result
                            disp("Trade declined.")
                        end
                    
                    else
                        
                        % If the trade is invalid, return the result
                        disp("Error: Trade invalid.")
                        
                    end
                    
                else
                    
                    % Determine whether the trade is valid
                    [trade, valid] = board.tradePlayer(player, x, toTrade, fromTrade, toNum, fromNum);
                    
                    if valid
                        
                        % Prompt the other player to approve/deny the trade
                        y = input("Does Player " + string(x) + " approve? (y/n): ", 's');
                        if strcmp(y, "y")
                            % If they approve, conduct the trade
                            board = trade; disp("Trade accepted.")
                        else
                            % Else, return the result
                            disp("Trade declined.")
                        end
                        
                    else
                        
                        % If the trade is invalid, return the result
                        disp("Error: Trade invalid.")
                        
                    end
                    
                end

            case Type.pass
                
                FLAG = false; % Set FLAG to false (break loop)

        end
        
        % Refresh the board and print resources
        if ~isempty(f); board.plotBoard(f); else; board.plotBoard(); end; printResources();
    
    end
    
end

% Function for printing resources
    function printResources()
        
        for p = 1:numPlayers
            disp("(Player " + string(p) + ") Brick: " + string(board.players{p}.cards.brick) + ...
                ", Sheep: " + string(board.players{p}.cards.sheep) + ", Stone: " + ...
                string(board.players{p}.cards.stone) + ", Wheat: " + ...
                string(board.players{p}.cards.wheat) + ", Wood: " + ...
                string(board.players{p}.cards.wood) + ", Road: " + ...
                string(board.players{p}.cards.buildRoad) + ", Knight: " + ...
                string(board.players{p}.cards.knight) + ", Monopoly: " + ...
                string(board.players{p}.cards.monopoly) + ", Plenty: " + ...
                string(board.players{p}.cards.plenty) + ", Victory: " + ...
                string(board.players{p}.cards.victoryPoint))
        end
        
    end

end