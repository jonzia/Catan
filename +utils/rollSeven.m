function [actions, log] = rollSeven(board, player)

% -------------------------------------------------------------------------
% This function determines possible future boards given the current board
% and the current player. The actions reflect choices the player has upon
% rolling a seven (after discarding cards if necessary).
% -------------------------------------------------------------------------

% Set placeholder for return values
actions = {}; log = {};

% The player may move the thief to any position, and take a resource from
% any player

% For each tile...
for i = 1:19
    % If the thief is already on the tile, skip the tile
    if board.tiles{i}.hasThief; continue; end
    
    % Get a list of non-self players with nodes bordering the tile
    players = [];
    for j = 1:length(board.nodes)
        if board.nodes{j}.structure ~= Structure.none && any(ismember(board.nodes{j}.tiles, i))
            players = [players board.nodes{j}.player];
        end
    end; players(players == player) = []; players = unique(players);

    % If there is no player from which to steal, return action
    if isempty(players)
        [actions{end + 1}, ~] = board.moveThief(i, player, 0);
        % Add an entry to the log
        log{end + 1} = Action(Type.moveThief, {i, 0});
        continue
    end

    % If there are one or more players from which to steal, return
    % stealing from each player as a separate action
    if ~isempty(players)
        for j = 1:length(players)
            [actions{end + 1}, ~] = board.moveThief(i, player, players(j));
            % Add an entry to the log
            log{end + 1} = Action(Type.moveThief, {i, players(j)});
        end
    end
    
end

end