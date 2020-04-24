function [results, VP] = runMonteCarlo(varargin)

% -------------------------------------------------------------------------
% This function runs a Monte Carlo simulation of a single game using a
% provided model or random action selection.
% 
% Arguments (optional):
% - model
% - epsilon
% - lambda
% - numPlayers
% - maxActions
% -------------------------------------------------------------------------

% Set placeholders for log and results
results = {}; VP = [];

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'model'); model = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'epsilon'); epsilon = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'lambda'); lambda = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'numPlayers'); numPlayers = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'maxActions'); maxActions = varargin{arg + 1};
        end
    end
end

% Set defaults for optional arguments
if ~exist('model', 'var'); model = []; end
if ~exist('epsilon', 'var'); epsilon = 0.5; end
if ~exist('lambda', 'var'); lambda = 1000; end
if ~exist('numPlayers', 'var'); numPlayers = 2; end
if ~exist('maxActions', 'var'); maxActions = 5; end

% Initialize and visualize game board
board = Board(numPlayers); % board.plotBoard(); f = gcf;

% -------------------------------------------------------------------------
% Initial Structure Placement
% -------------------------------------------------------------------------

% Order goes Player 1, 2, ... numPlayers, numPlayers, numPlayers - 1, ... 1
order = [1:numPlayers, numPlayers:-1:1];
for i = order
    % Return all possible actions regarding house selection
    [actions, ~] = board.initialHouse(i);
    % Rank the actions based on the model
    rank = utils.rankActions(actions, []);
    % Select a greedy action with probability epsilon
    if rand() < epsilon; board = actions{rank == 1};
    else; board = actions{randi([1, length(actions)])};
    end
end

% Record board state and victory points
[results, VP] = utils.record(board, results, VP);

% Distribute starting resources
for i = 1:12; board.dice = i; if i ~= 7; board = board.distribute(); end; end

% -------------------------------------------------------------------------
% Begin Turn-Based Game
% -------------------------------------------------------------------------

% Create flag to determine whether game is over and initialize turn counter
gameOVER = false; turnCounter = 1;

% Loop through game while victory conditions have not been met
while ~gameOVER
    
    % Determine current player
    player = mod(turnCounter, numPlayers); if player == 0; player = numPlayers; end
    
    % ---------------------------------------------------------------------
    % Roll Dice / Distribute Resources / Move Thief / Discard
    % ---------------------------------------------------------------------
    
    % Roll Dice
    board = board.roll();
    
    % If a 7 was not rolled, distribute resources
    if board.dice ~= 7; board = board.distribute();
    else
        % If a 7 was rolled, determine whether each player must discard
        for i = 1:numPlayers
            % Get possible discard actions
            [actions, ~] = utils.discard(board, i);
            % If the player does not need to discard, continue
            if isempty(actions); continue; end
            % Else, select the optimal action with probability epsilon
            rank = utils.rankActions(actions, []);
            if rand() < epsilon; board = actions{rank == 1};
            else; board = actions{randi([1, length(actions)])};
            end
        end
        % Upon discarding, the current player may move the thief
        [actions, ~] = utils.rollSeven(board, player);
        % Select the optimal action with probability epsilon
        rank = utils.rankActions(actions, []);
        if rand() < epsilon; board = actions{rank == 1};
        else; board = actions{randi([1, length(actions)])};
        end
        
        % Record board state and victory points
        [results, VP] = utils.record(board, results, VP);
        
    end
    
    % ---------------------------------------------------------------------
    % Conduct Trades / Build Structures / Play Chance Cards
    % ---------------------------------------------------------------------
    
    % Enforce action counter and end turn on pass action
    turnFLAG = true; counter = 0;
    
    % Create a placeholder for prohibited trades this turn
    prohibited = {};
    
    while turnFLAG
        
        % Determine possible actions
        [actions, log] = utils.getActions(board, player);
        
        % Evaluate actions, and choose optimal action with prob epsilon
        rank = utils.rankActions(actions, []);
        if rand() < epsilon
            
            % Set placeholders for selecting non-prohibited action
            prohibFLAG = true; c = 1;
            % If the log does not contain this action, proceed
            while prohibFLAG
                % Get the optimal index
                idx = rank(rank == c);
                % If the log does not contain this action, proceed
                if ~utils.logContains(prohibited, log{idx}); prohibFLAG = false;
                else; c = c + 1;
                end
            end
            
        else; prohibFLAG = true;
            
            % Find a non-prohibited random index
            while prohibFLAG
                % Get a random index
                idx = randi([1, length(actions)]);
                % If the log does not contain this action, proceed
                if ~utils.logContains(prohibited, log{idx}); prohibFLAG = false; end
            end
            
        end
        
        % If the action is not a trade with a player, proceed
        if log{idx}.actionType ~= Type.tradePlayer; board = actions{idx};
        else
            % Else, have the target player rank the proposed board states
            rank = utils.rankActions({board, actions{idx}}, []);
            % If they find the trade favorable, proceed; else, add the
            % trade to the temporary prohibited turn list and pass
            if rank(2) == 1; board = actions{idx};
            else; prohibited{end + 1} = log{idx};
            end
        end
        
        % Increment the turn counter
        counter = counter + 1;
        
        % If the action type is "pass" end the turn
        if log{idx}.actionType == Type.pass; turnFLAG = false;
            % Else, if the turn counter has been exceeded, end the turn
        elseif counter >= maxActions; turnFLAG = false;
        end
        
        % Record board state and victory points
        [results, VP] = utils.record(board, results, VP);
        
    end
    
    % Determine whether the maximum number of turns have been made
    turnCounter = turnCounter + 1; if turnCounter >= lambda; gameOVER = true; end
    
    % Determine whether win condition has been met by any player
    for i = 1:numPlayers
        board = board.computeVP(i);     % Compute victory points by player
        % If the player has won, end the game
        if board.players{i}.VP_private == 10; gameOVER = true; end
    end
    
    disp(turnCounter)
    
end

end

