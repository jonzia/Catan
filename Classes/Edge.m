classdef Edge
    
    % Class containing properties and methods for edges
    
    % Class Properties
    properties (SetAccess = public, GetAccess = public)
        number                  % Edge number
        nodePair                % Pair of nodes joined by edge
        structure   Structure   % Structure present on edge
        player                  % Player to which structure belongs
    end
    
    % Class Methods
    methods (Access = public)
        
        % Class constructor
        function obj = Edge(number, nodePair)
            obj.number = number; obj.structure = Structure.none;
            obj.player = []; obj.nodePair = nodePair;
        end
        
        % Add structure to Edge
        function obj = addStructure(obj, structure, player)
            
            % Check validity of input arguments
            if structure ~= Structure.road; ...
                    disp("Error in Edge.addStructure(): Only roads can be added to edges"); end
            if player < 1 || player > obj.numPlayers
                disp("Error in Edge.addStructure(): Invalid number of players")
            end
            
            % Assign object properties
            obj.structure = structure; obj.player = player;
            
        end
        
    end
    
end