function state = getState(board, player)

% -------------------------------------------------------------------------
% This function returns a board state in vector form given the game board,
% from the perspective of a particular player.
%
% State Structure:
% [A, B, C, D, E, F, (G, H, I...)]
% A     indices 1 - 19      Resource on tiles 1 - 19
%                           0 = desert, 1 = brick, 2 = sheep, 3 = stone
%                           4 = wheat, 5, = wood
% B     indices 20 - 28     Harbor type on harbor 1 - 9
%                           0 = 3:1 any, 1 = 2:1 brick, 2 = 2:1 sheep
%                           3 = 2:1 stone, 4 = 2:1 wheat, 5 = 2:1 wood
% C     indices 29 - 38     Number of each card held by player
%                           #brick, #sheep, #stone, #wheat, #wood
%                           #buildRoad, #knight, #monopoly, #plenty
%                           #victoryPoint
% D     indices 39 - 92     Structure on each node
%                           0 = none, 1/2 = house/city for P1
%                           3/4 = house/city for P2, ...
% E     indices 93 - 164    Structure on each edge
%                           0 = none, 1 = road for P1, 2 = road for P2, ...
% F     index 165           Thief location in [1, 19]
% G     indices 166 - 175   Number of cards held by first opposing player
% H     Indices 176 - 185   Number of cards held by second opposing player
% ...
% -------------------------------------------------------------------------

% Set placeholder for return value based on number of players
state = zeros(165 + 10*(board.numPlayers - 1), 1);

% Initialize state index counter
idx = 1;

% -------------------------------------------------------------------------
% A (Resources on Tiles)
% -------------------------------------------------------------------------

% For each tile...
for i = 1:length(board.tiles)
    % Set the state of the tile based on the resource
    switch board.tiles{i}.resource
        case Resource.desert; state(idx) = 0;
        case Resource.brick; state(idx) = 1;
        case Resource.sheep; state(idx) = 2;
        case Resource.stone; state(idx) = 3;
        case Resource.wheat; state(idx) = 4;
        case Resource.wood; state(idx) = 5;
    end; inc();     % Increment state counter
end

% -------------------------------------------------------------------------
% B (Harbor Types)
% -------------------------------------------------------------------------

% For each harbor...
for i = 1:length(board.harbors)
    % Set the state of the harbor based on the resource
    switch board.harbors{i}.resource
        case Resource.all; state(idx) = 0;
        case Resource.brick; state(idx) = 1;
        case Resource.sheep; state(idx) = 2;
        case Resource.stone; state(idx) = 3;
        case Resource.wheat; state(idx) = 4;
        case Resource.wood; state(idx) = 5;
    end; inc();     % Increment state counter
end

% -------------------------------------------------------------------------
% C (Cards by Player)
% -------------------------------------------------------------------------

% For each card type, set the state and increment the counter
state(idx) = board.players{player}.cards.brick; inc();
state(idx) = board.players{player}.cards.sheep; inc();
state(idx) = board.players{player}.cards.stone; inc();
state(idx) = board.players{player}.cards.wheat; inc();
state(idx) = board.players{player}.cards.wood; inc();
state(idx) = board.players{player}.cards.buildRoad; inc();
state(idx) = board.players{player}.cards.knight; inc();
state(idx) = board.players{player}.cards.monopoly; inc();
state(idx) = board.players{player}.cards.plenty; inc();
state(idx) = board.players{player}.cards.victoryPoint; inc();

% -------------------------------------------------------------------------
% D (Structures on Nodes)
% -------------------------------------------------------------------------

% For each node...
for i = 1:length(board.nodes)
    % Set the state based on the structure on the node and its owner
    switch board.nodes{i}.structure
        case Structure.none; state(idx) = 0;
        case Structure.house
            % 1 for player 1, 3 for player 2, 5, for player 3...
            state(idx) = 2*(board.nodes{i}.player - 1) + 1;
        case Structure.city
            % 2 for player 1, 4 for player 2, 6 for player 3...
            state(idx) = 2*board.nodes{i}.player;
    end; inc();     % Increment state counter
end

% -------------------------------------------------------------------------
% E (Structures on Edges)
% -------------------------------------------------------------------------

% For each edge...
for i = 1:length(board.edges)
    % Set the state based on the structure on the edge and its owner
    switch board.edges{i}.structure
        case Structure.none; state(idx) = 0;
        case Structure.road; state(idx) = board.edges{i}.player;
    end; inc();     % Increment state counter
end


% -------------------------------------------------------------------------
% F (Thief)
% -------------------------------------------------------------------------

% Return the tile currently occupied by the thief
for i = 1:19
    if board.tiles{i}.hasThief; state(idx) = i; break; end
end; inc();     % Incement state counter

% -------------------------------------------------------------------------
% G, H, I... (Cards for Additional Players)
% -------------------------------------------------------------------------

% For each player...
for i = 1:board.numPlayers
    % ... besides the current player
    if i == player; continue; end
    % Set the state for each card type, and increment the counter
    state(idx) = board.players{player}.cards.brick; inc();
    state(idx) = board.players{player}.cards.sheep; inc();
    state(idx) = board.players{player}.cards.stone; inc();
    state(idx) = board.players{player}.cards.wheat; inc();
    state(idx) = board.players{player}.cards.wood; inc();
    state(idx) = board.players{player}.cards.buildRoad; inc();
    state(idx) = board.players{player}.cards.knight; inc();
    state(idx) = board.players{player}.cards.monopoly; inc();
    state(idx) = board.players{player}.cards.plenty; inc();
    state(idx) = board.players{player}.cards.victoryPoint; inc();
end

% Function for incrementing counter
    function inc()
        idx = idx + 1;
    end

end