function [results, VP] = record(board, results, VP)

% This function records the board state and current victory points.

% Create vector of board states and append to log
states = cell(1, board.numPlayers);
for i = 1:board.numPlayers
    states{1, i} = utils.getState(board, i);
end; results = [results; states];

% Create vector of victory points and append to log
points = zeros(1, board.numPlayers);
for i = 1:board.numPlayers
    % Compute victory points for player
    board = board.computeVP(i);
    % Assign to log
    points(i) = board.players{i}.VP_private;
end; VP = [VP; points];

end

