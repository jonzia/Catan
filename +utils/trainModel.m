function [net, winPercentage, data, targets] = trainModel(varargin)

% -------------------------------------------------------------------------
% This function trains a neural network model for each simulated player via
% Monte Carlo simulations.
%
% Arguments (optional):
% - numPlayers      Int         Number of players (default: 2)
% - lrInit          Dbl         Initial learning rate (d: 0.001)
% - lrDecay         Dbl         Learning rate decay factor (d: 0.1)
% - lrDecayCounter  Int         Number of times to decay LR (d: 3)
% - numRounds       Int         Number of rounds of training (d: 10)
% - numGames        Int         Number of games per round (d: 100)
% - numTest         Int         Number of test games per round (d: 10)
% - split           Dbl         % of data used for training (d: 0.7)
% - dropout         Dbl         % dropout (d: 0.2)
% - maxEpochs       Int         Maximum training epochs (d: 100)
% - batchSize       Int         Minibatch size (d: 32)
% - patience        Int         Validation patience (d: 5)
% - epsilon         Dbl         Initial epsilon (d: 0.75)
% - lambda          Int         Maximum turns per game (d: 1000)
% - maxActions      Int         Maximum number of actions / turn (d: 5)
% - validFreq       Int         Validation frequency (d: 10)
% -------------------------------------------------------------------------

% Set defaults for optional arguments
numPlayers = 2; lrInit = 0.001; lrDecay = 0.1;
lrDecayCounter = 3; numRounds = 10; numGames = 100; numTest = 10;
split = 0.7; dropout = 0.2; maxEpochs = 100; batchSize = 32;
patience = 5; epsilon = 0.75; lambda = 1000; maxActions = 5;
validFreq = 10;

% Parse optional input arguments
if ~isempty(varargin)
    for arg = 1:length(varargin)
        if strcmp(varargin{arg}, 'numPlayers'); numPlayers = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'lrInit'); lrInit = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'lrDecay'); lrDecay = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'lrDecayCounter'); lrDecayCounter = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'numRounds'); numRounds = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'numGames'); numGames = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'numTest'); numTest = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'split'); split = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'dropout'); dropout = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'maxEpochs'); maxEpochs = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'batchSize'); batchSize = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'patience'); patience = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'epsilon'); epsilon = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'lambda'); lambda = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'maxActions'); maxActions = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'validFreq'); validFreq = varargin{arg + 1};
        end
    end
end

% Define model architecture
layers = [
    sequenceInputLayer(165 + (numPlayers - 1)*10,"Name","sequence")
    fullyConnectedLayer(100,"Name","fc_1","BiasInitializer","narrow-normal","WeightsInitializer","narrow-normal")
    reluLayer("Name","relu_1")
    dropoutLayer(dropout,"Name","dropout_1")
    fullyConnectedLayer(25,"Name","fc_2","BiasInitializer","narrow-normal","WeightsInitializer","narrow-normal")
    reluLayer("Name","relu_2")
    dropoutLayer(dropout,"Name","dropout_2")
    fullyConnectedLayer(1,"Name","fc_3","BiasInitializer","narrow-normal","WeightsInitializer","narrow-normal")
    reluLayer("Name","relu_3")
    regressionLayer("Name","regressionoutput")];

h = waitbar(0, 'Please wait...');

% Initialize counter and win percentage placeholders
counter = 0; winPercentage = zeros(numRounds, 1);

% Set data and target placeholders
data = []; targets = [];

% For each round...
for rnd = 1:numRounds
    
    % Initialize placeholder for round data/targets
    roundData = []; roundTargets = [];
    
    % For each game in the round...
    for game = 1:numGames
        
        % Update waitbar
        waitbar(game/numGames, h, "Round " + string(rnd) + ": Game " + string(game))
        
        % Perform monte carlo simulation randomly if first round
        if rnd == 1
            [results, vp] = utils.runMonteCarlo('numPlayers', numPlayers, ...
                'lambda', lambda, 'maxActions', maxActions);
        else
            % Otherwise, use the model
            models = cell(numPlayers, 1); models(:) = {net};
            [results, vp] = utils.runMonteCarlo('numPlayers', numPlayers, 'model', models, ...
                'epsilon', epsilon, 'lambda', lambda, 'maxActions', maxActions);
        end
        
        % Get results from current game
        gameData = []; gameTargets = [];
        for i = 1:numPlayers
            % Get data vectors
            gameData = [gameData; results(:, i)];
            % Get target outputs
            temp = cell(size(results, 1), 1); temp(:) = {vp(end, i)};
            gameTargets = [gameTargets; temp];
        end
        
        % Save game data
        data = [data; gameData]; targets = [targets; gameTargets];
        roundData = [roundData; gameData]; roundTargets = [roundTargets; gameTargets];
        
        % Get results
        for i = 1:numPlayers
            % Get data vectors
            data = [data; results(:, i)];
            % Get target outputs
            temp = cell(size(results, 1), 1); temp(:) = {vp(end, i)};
            targets = [targets; temp];
        end
        
        % Get the index of the games used for training (vs. validation)
        if game == round(split*10); idx = size(roundData, 1); end
        
    end
    
    % Train/validate only on data from the current round (transfer)
    % Split training and validation data
    trainData = roundData(1:idx, :); validData = roundData(idx+1:end, :);
    trainLabels = roundTargets(1:idx, :); validLabels = roundTargets(idx+1:end, :);
    
    % Set initial learning rate
    LR = lrInit;
    
    % Manual learning rate decay
    for i = 1:lrDecayCounter
    
        % Set training options
        if i ~= lrDecaycounter
            options = trainingOptions('adam', 'MaxEpochs', maxEpochs, 'Plots', 'training-progress', ...
                'Verbose', 0, 'MiniBatchSize', batchSize, 'Shuffle', 'every-epoch', ...
                'ValidationPatience', patience, 'InitialLearnRate', LR, ...
                'ExecutionEnvironment', 'gpu', 'ValidationFrequency', validFreq, ...
                'ValidationData', {validData, validLabels});
        else
            options = trainingOptions('adam', 'MaxEpochs', maxEpochs, 'Plots', 'training-progress', ...
                'Verbose', 0, 'MiniBatchSize', batchSize, 'Shuffle', 'every-epoch', ...
                'ValidationPatience', 2, 'InitialLearnRate', LR, ...
                'ExecutionEnvironment', 'gpu', 'ValidationFrequency', validFreq, ...
                'ValidationData', {validData, validLabels});
        end

        % Train network
        if counter == 0; net = trainNetwork(trainData, trainLabels, layers, options);
        else
            net_2 = trainNetwork(data, targets, net.Layers, options);
            clear net; net = net_2;
        end
        
        % Decay learning rate
        counter = counter + 1; LR = lrDecay*LR;
        
    end
    
    % Test model against random policy
    for i = 1:numTest
        waitbar(i/numTest, h, "Testing Model " + string(i) + "/" + string(numTest));
        [~, vp] = utils.runMonteCarlo('numPlayers', numPlayers, 'model', ...
            {net, []}, 'epsilon', epsilon, 'lambda', lambda, 'maxActions', maxActions);
        if vp(end, 1) > vp(end, 2); winPercentage(rnd) = winPercentage(rnd) + 1/numTest; end
    end
    
    % Save the workspace after each round
    save("round_" + string(rnd) + ".mat")
    
end

% Close waitbar
close(h);

end

