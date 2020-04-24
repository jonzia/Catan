function obj = distribute(obj)

% -------------------------------------------------------------------------
% This function distributes resources to each player after a non-7 roll.
% -------------------------------------------------------------------------

% Verify that the player did not roll a 7
if obj.dice == 7
    disp("Error in Board.distribute(): Roll number invalid")
    return
end

% For each node...
for i = 1:length(obj.nodes)
    
    % If there is no structure on the node, continue
    if obj.nodes{i}.structure == Structure.none; continue; end
    
    % For each tile on the node...
    for j = 1:length(obj.nodes{i}.tiles)
        
        % Get the tile
        tile = obj.nodes{i}.tiles(j);
        
        % If the tile has the proper number AND does not have a thief,
        % award the player with the structure the tile's resource, one for
        % house and two for city.
        if ~obj.tiles{tile}.hasThief && obj.tiles{tile}.number == obj.dice
            switch obj.nodes{i}.structure
                case Structure.house
                    % Take a resource from the bank, if possible
                    [obj, ~] = obj.tradeBank(obj.nodes{i}.player, obj.tiles{tile}.resource, -1);
                case Structure.city
                    [obj, isValid] = obj.tradeBank(obj.nodes{i}.player, obj.tiles{tile}.resource, -2);
                    if ~isValid
                        % Try to take one resource if two are not available
                        [obj, ~] = obj.tradeBank(obj.nodes{i}.player, obj.tiles{tile}.resource, -1);
                    end
            end
        end
        
    end
    
end

end