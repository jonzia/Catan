classdef Node
    
    % Class containing properties and methods for board nodes
    
    % Class Properties
    properties (SetAccess = public, GetAccess = public)
        number                  % Node number
        tiles                   % Indices of tiles adjacent to node
        structure   Structure   % Structure on node
        player                  % Player to which structure belongs
        %harbor      Harbor      % Harbor on node, if any
        coordinates             % (x,y)-coordinates of node
    end
    
    % Class Methods
    methods (Access = public)
        
        % Class constructor
        function obj = Node(number, coordinates)
            % Set class properties
            obj.number = number; obj.coordinates = coordinates;
            obj.tiles = []; obj.player = []; obj.structure = Structure.none;
        end
        
        % Add structure to node
        function obj = addStructure(obj, structure, player)
            
            % Check validity of input arguments
            if structure ~= Structure.house || structure ~= Structure.city
                disp("Error in Node.addStructure(): Only houses and cities may be added to nodes")
            end
            if player < 1 || player > obj.numPlayers
                disp("Error in Node.addStructure(): Invalid player number")
            end
            
            % Assign arguments to object properties
            obj.structure = structure; obj.player = player;
            
        end
        
    end
    
end