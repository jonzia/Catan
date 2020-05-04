classdef Action
    
    % Class containing properties and methods related to actions
    
    % Class properties
    properties (SetAccess = public, GetAccess = public)
        actionType  Type    % Type of action
        metadata            % Metadata associated with action
    end
    
    % Class Methods
    methods (Access = public)
        
        % Class constructor
        function obj = Action(actionType, varargin)
            % Return an error if actionType is not a Type
            if ~isa(actionType, 'Type')
                disp("Error in Action(): ActionType must have type Type")
                obj.actionType = []; obj.metadata = []; return
            end
            % For .buildHouse, .buildCity, .buildRoad, varargin{1}
            % describes the node or edge upon which the structure was
            % placed. This is intended to support action descriptions. For
            % .playChance, it should contain a Card object. For .tradeBank,
            % it should include {Resource.given Resource.taken numTraded}. For
            % .tradePlayer, it should include {Resource.given
            % Resource.taken OpposingPlayer}. For .moveThief, it should
            % include {tile targetPlayer}. For .discard, it should include
            % the number of cards discarded.
            if ~isempty(varargin); obj.metadata = varargin{1}; end
            % Set action type
            obj.actionType = actionType;
        end
        
        % Generate description for action
        function description = getDescription(obj, player)
            
            % Description depends on action type
            switch obj.actionType
                case Type.buildCity
                    description = "Player " + string(player) + " builds city on node " + string(obj.metadata);
                case Type.buildHouse
                    description = "Player " + string(player) + " builds house on node " + string(obj.metadata);
                case Type.buildRoad
                    description = "Player " + string(player) + " builds road on node " + string(obj.metadata);
                case Type.playChance
                    description = "Player " + string(player) + " plays Card: " + string(obj.metadata);
                case Type.tradeBank
                    description = "Player " + string(player) + " trades " + string(obj.metadata{3}) + ...
                        " " + string(obj.metadata{1}) + " to bank for 1 " + string(obj.metadata{2});
                case Type.tradePlayer
                    description = "Player " + string(player) + " trades " + string(obj.metadata{1}) + ...
                        " to Player " + string(obj.metadata{3}) + " for " + string(obj.metadata{2});
                case Type.pass
                    description = "Player " + string(player) + " passed";
                case Type.moveThief
                    description = "Player " + string(player) + " moved thief to tile " + string(obj.metadata{1}) + ...
                        " and stole from Player " + string(obj.metadata{2});
                case Type.discard
                    description = "Player " + string(player) + " discarded " + string(obj.metadata) + " cards";
            end
            
        end
        
    end
    
end