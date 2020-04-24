function contains = logContains(log, item)

% Determine whether the log contains an Action.

% Set placeholder for return value
contains = false;

% For each log item...
for i = 1:length(log)
    % Determine whether it matches the action
    if log{i}.actionType == item.actionType
        
        % If the metadata is the same length, compare further
        if length(log{i}.metadata) == length(item.metadata)
            
            % Do the cells match?
            cellMatch = true;
            
            % For each cell...
            for j = 1:length(log{i}.metadata)
                % Do the cells match? If not, indicate this
                if log{i}.metadata{j} ~= item.metadata{j}; cellMatch = false; end
            end
            
            % If no cells were mismatched, return true
            if cellMatch; contains = true; return; end
            
        end
        
    end
end

end

