classdef Board
    
    % Class containing properties and methods for game board
    
    % Class Properties
    properties (SetAccess = public, GetAccess = public)
        tiles           % List of tiles, arranged in order      (Tile)
        harbors         % List of harbors, arranged in order    (Harbor)
        numPlayers      % Number of players                     (Int)
        turn            % Turn counter                          (Int)
        bank            % Struct containing bank card counts    (Struct -> Int)
        players         % List of players, arranged in order    (Player)
        dice            % Value of current roll                 (Int)
        nodes           % List of nodes, arranged in order      (Node)
        edges           % List of edges, arranged in order      (Edge)
        adjacency       % Adjacency matrix, weighed by edge #   (Array)
    end
    
    % Class Methods
    methods (Access = public)
        
        % Class constructor
        function obj = Board(numPlayers)
            
            % Verify argument data type
            if numPlayers ~= round(numPlayers) || numPlayers < 2 || numPlayers > 4
                disp("Error in Board(): Argument in Position 1 must be an integer value between 2 and 4");
            end
            
            % Set initial properties
            obj.numPlayers = numPlayers; obj.turn = 1;
            
            % Initialize card counts
            obj.bank.brick = 19; obj.bank.buildRoad = 2;
            obj.bank.knight = 13; obj.bank.monopoly = 2;
            obj.bank.plenty = 1; obj.bank.sheep = 19; 
            obj.bank.stone = 19; obj.bank.victoryPoint = 5; 
            obj.bank.wheat = 19; obj.bank.wheat = 19;
            
            % Initialize game board
            obj = obj.initialize();
            
            % Initialize players
            obj.players = cell(obj.numPlayers, 1);  % Vector of players
            for i = 1:obj.numPlayers
                obj.players{i} = Player("Player " + string(i), i);
            end
            
        end
        
        % Initialize game board
        obj = initialize(obj, varargin)
        
        % Plot the game board
        obj = plotBoard(obj, varargin)
        
        % Roll dice
        function obj = roll(obj); obj.dice = randi([1, 6], 1) + randi([1, 6], 1); end
        
    end
    
end