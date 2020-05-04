function board = gameManager(numPlayers, computer, model, varargin)

% -------------------------------------------------------------------------
% This function manages a single turn of the game, based on the current
% player, which player is the computer, and the trained model.
%
% Arguments (required)
% - numPlayers  Int     Number of players
% - computer    Int     Computer player
% - model       Model   Trained quality function
%
% Arguments (optional)
% - roll        Bool    Indicates whether dice will be rolled manually (d: false)
% - maxActions  Int     Maximum number of actions by computer (d: inf)
% -------------------------------------------------------------------------

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'roll'); roll = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'maxActions'); maxActions = varargin{arg + 1};
        end
    end
end

% Set defaults for optional arguments
if ~exist('roll', 'var'); roll = false; end
if ~exist('maxActions', 'var'); maxActions = inf; end

% Initialize and plot the board
board = Board(numPlayers); board.plotBoard();

% Set game flag and turn counter
FLAG = true; turn = 1;

% Continue the game until stop criteria are met
while FLAG
    
    % Run turn
    board = game.turnManager(board, turn, computer, model, 'roll', roll, 'maxActions', maxActions);
    
    % Increment turn counter
    turn = turn + 1;
    
    % Set placeholder for victory points
    vp = zeros(numPlayers, 1);
    % Compute and record victory points
    for i = 1:numPlayers; board = board.computeVP(i); vp(i) = board.players{i}.VP_private; end
    
    % If a player hits 10 victory points, end the game
    if max(vp) >= 10
        FLAG = false;
        % Get and display index of winning player
        [~, idx] = max(vp);
        disp("***** Player " + string(idx) + " wins with " + string(max(vp)) + " points! *****")
    end
    
end

end

