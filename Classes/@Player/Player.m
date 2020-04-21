classdef Player
    
    % Class containing properties and methods for players
    
    % Class Properties
    properties (SetAccess = public, GetAccess = public)
        number          % Player number
        name            % Player name
        cards           % Struct of cards held by player (Struct -> Int)
        victoryPoints   % Victory points earned by player
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
            obj.name = name; obj.number = number; obj.victoryPoints = 0;
            obj.cards.brick = 0; obj.cards.buildRoad = 0; obj.cards.knight = 0;
            obj.cards.monopoly = 0; obj.cards.plenty = 0; obj.cards.sheep = 0;
            obj.cards.stone = 0; obj.cards.victoryPoint = 0; obj.cards.wheat = 0;
            obj.cards.wood = 0; obj.victoryPoints = 0;
            
        end
        
    end
    
end