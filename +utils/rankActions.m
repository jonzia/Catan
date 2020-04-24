function rank = rankActions(actions, model, varargin)

% Return a random ranking (placeholder)
numActions = length(actions);
temp = 1:numActions;
rank = temp(randperm(length(actions)));

end

