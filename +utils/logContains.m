function contains = logContains(log, item)

% Determine whether the log contains an Action.

% For each log item...
for i = 1:length(log)
    % If it matches the item in question, return this result
    if isequal(log{i}, item); contains = true; return; end
end; contains = false; % Else, return false

end

