classdef Tile
    
    % Class containing properties and methods for board tiles
    
    % Class Properties
    properties (SetAccess = public, GetAccess = public)
        resource Resource   % Resource of tile
        number              % Die number corresponding to tile
        hasThief            % Does the tile have the thief?
        centerpoint         % (x,y)-coordinate of center point of tile
    end
    
    % Class Methods
    methods (Access = public)
        
        function obj = Tile(resource, number, centerpoint)
            
            % Verify input datatypes
            if ~isa(resource, 'Resource'); ...
                    disp("Error in Harbor(): Argument in position 1 must be of type Resource"); end
            if number ~= round(number); ...
                    disp("Error in Harbor(): Argument in position 2 must be an integer"); end
            
            
            % Set class properties
            obj.resource = resource; obj.number = number; obj.centerpoint = centerpoint;
            
            % If the resource is a desert tile, hasThief is true at start
            if obj.resource == Resource.desert; obj.hasThief = true; else; obj.hasThief = false; end
            
        end
        
    end
    
end