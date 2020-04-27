function rank = rankActions(actions, model, player)

% If there is no model provided, reutrn a random ranking
if isempty(model)
    numActions = length(actions); temp = 1:numActions;
    rank = temp(randperm(numActions)); return
end

% If there is a model, return a prediction for each action
score = zeros(length(actions), 1);
for i = 1:length(score)
    temp = model.predict({utils.getState(actions{i}, player)});
    score(i) = temp{1}(1); [~, rank] = sort(score, 'descend');
end

end

