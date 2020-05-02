function rank = rankActions(actions, model, player)

% Get number of actions
numActions = length(actions);

% If there is no model provided, reutrn a random ranking
if isempty(model)
    rank = randperm(numActions); return
end

% If there is a model, return a prediction for each action
score = zeros(numActions, 1);
for i = 1:numActions
    temp = model.predict({utils.getState(actions{i}, player)});
    score(i) = temp{1}(1);
end; [~, rank] = sort(score, 'descend');

end

