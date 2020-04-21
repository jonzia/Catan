classdef Harbor
   
    % Class containing properties and methods for harbors
    
    % Class properties
    properties (SetAccess = public, GetAccess = public)
        resource Resource   % Type of resource which may be traded
        cost                % Number of resource cards required
    end
    
    % Class Methods
    methods (Access = public)
        
        function obj = Harbor(resource, cost)
            
            % Verify input datatypes
            if ~isa(resource, 'Resource'); ...
                    disp("Error in Harbor(): Argument in position 1 must be of type Resource"); end
            if cost ~= round(cost); ...
                    disp("Error in Harbor(): Argument in position 2 must be an integer"); end
            
            % Set class properties
            obj.resource = resource; obj.cost = cost;
            
        end
        
    end
    
end