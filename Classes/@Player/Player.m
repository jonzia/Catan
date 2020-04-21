classdef Player
    
    % Class containing properties and methods for players
    
    % Class Properties
    properties (SetAccess = public, GetAccess = public)
        number          % Player number
        name            % Player name
        cards           % Struct of cards held by player (Struct -> Int)
        structures      % Struct of structures available to be built by player (Struct -> Int)
        VP_public       % Victory points earned by player (public)
        VP_private      % Victory points earned by player, including chance cards
        knight_cards    % Knight cards played
        hasArmyCard     % Does the player have the largest army?
        road_length     % Length of longest road
        adjacency       % Adjacency matrix of roads belonging to player
    end
    
    % Class Methods
    methods (Access = public)
        
        % Class constructor
        function obj = Player(name, number)
            
            % Verify input argument data types
            if ~isstring(name); ...
                    disp("Error in Player(): Argument in Position 1 must be a string"); end
            if number ~= round(number); ...
                    disp("Error in Player(): Argument in Position 1 must be an integer"); end
            
            % Set property values
            obj.name = name; obj.number = number; obj.VP_public = 0; obj.VP_private = 0;
            obj.knight_cards = 0; obj.hasArmyCard = false; obj.road_length = 0;
            
            obj.cards.brick = 0; obj.cards.buildRoad = 0; obj.cards.knight = 0;
            obj.cards.monopoly = 0; obj.cards.plenty = 0; obj.cards.sheep = 0;
            obj.cards.stone = 0; obj.cards.victoryPoint = 0; obj.cards.wheat = 0;
            obj.cards.wood = 0;
            
            obj.structures.house = 5; obj.structures.city = 4;
            obj.structures.road = 15;
            
        end
        
    end
    
end