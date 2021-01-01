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
% - maxTurns        Int         Maximum turns per game (d: 1000)
% - maxActions      Int         Maximum number of actions / turn (d: 5)
% - maxTrades       Int         Maximum number of trades / turn (d: 5)
% - validFreq       Int         Validation frequency (d: 10)
% - path            String      Path to save data (d: "")
% - lambda          Int         Number of steps for TD learning (d: inf)
% - hidden          [Int]       Vector of hidden layer sizes (d: [100, 50, 25, 10])
% -------------------------------------------------------------------------

% Set defaults for optional arguments
numPlayers = 2; lrInit = 0.001; lrDecay = 0.1;
lrDecayCounter = 3; numRounds = 10; numGames = 100; numTest = 10;
split = 0.7; dropout = 0.2; maxEpochs = 100; batchSize = 32;
patience = 5; epsilon = 0.75; maxTurns = 1000; maxActions = 5; maxTrades = 5;
validFreq = 10; path = ""; lambda = inf; hidden = [100, 50, 25, 10];

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
        elseif strcmp(varargin{arg}, 'maxTurns'); maxTurns = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'maxActions'); maxActions = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'maxTrades'); maxTrades = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'validFreq'); validFreq = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'path'); path = varargin{arg + 1};
        elseif strcmp(varargin{arg}, 'lambda'); lambda = varargin{arg + 1};
        end
    end
end

% Initial input layer
layers = sequenceInputLayer(165 + (numPlayers - 1)*10, "Name", "sequence");

% Hidden layers
for i = 1:length(hidden)
    layers = [layers fullyConnectedLayer(hidden(i), "Name", "fc_" + string(i))];
    layers = [layers reluLayer("Name", "relu_" + string(i))];
    layers = [layers dropoutLayer(dropout, "Name", "dropout_" + string(i))];
end

% Output layer
layers = [layers fullyConnectedLayer(1,"Name","fc_out")];
layers = [layers reluLayer("Name","relu_out")];
layers = [layers regressionLayer("Name","regressionoutput")];
%,"BiasInitializer","narrow-normal","WeightsInitializer","narrow-normal")

h = waitbar(0, 'Please wait...');

% Initialize placeholders
winPercentage = zeros(numRounds, 1); data = []; targets = []; counter = 0;

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
                'maxTurns', maxTurns, 'maxActions', maxActions, 'maxTrades', maxTrades);
        else
            % Otherwise, use the model
            models = cell(numPlayers, 1); models(:) = {net};
            [results, vp] = utils.runMonteCarlo('numPlayers', numPlayers, 'model', models, ...
                'epsilon', epsilon, 'maxTurns', maxTurns, 'maxActions', maxActions, 'maxTrades', maxTrades);
        end
        
        % Get results from current game
        gameData = []; gameTargets = [];
        for i = 1:numPlayers
            
            % Get data vectors
            gameData = [gameData; results(:, i)];
            
            % Get target outputs
            if isinf(lambda)
                % If lambda is infinity, label all moves by the final label
                temp = cell(size(results, 1), 1); temp(:) = {vp(end, i)};
                gameTargets = [gameTargets; temp];
            else
                % Otherwise, forecast UP TO lambda moves in the future
                temp_vp = vp(:, i); temp_vp(end:end+lambda) = temp_vp(end);
                temp_vp(1:size(results, 1)) = temp_vp(lambda:size(results, 1)+lambda);
                temp = cell(size(results, 1), 1);
                for j = 1:length(temp); temp{j} = temp_vp(j); end
                gameTargets = [gameTargets; temp];
            end
            
        end
        
        % Save game data
        data = [data; gameData]; targets = [targets; gameTargets];
        roundData = [roundData; gameData]; roundTargets = [roundTargets; gameTargets];
        
        % Get the index of the games used for training (vs. validation)
        if game == round(split*numGames); idx = size(roundData, 1); end
        
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
        if i ~= lrDecayCounter
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
            net_2 = trainNetwork(trainData, trainLabels, net.Layers, options);
            clear net; net = net_2;
        end
        
        % Decay learning rate
        counter = counter + 1; LR = lrDecay*LR;
        
    end
    
    % Set up models for testing
    testModels = cell(numPlayers, 1); testModels{end} = net;
    
    % Test model against random policy
    for i = 1:numTest
        waitbar(i/numTest, h, "Testing Model " + string(i) + "/" + string(numTest));
        [~, vp] = utils.runMonteCarlo('numPlayers', numPlayers, 'model', ...
            testModels, 'epsilon', 1, 'maxTurns', maxTurns, 'maxActions', maxActions, 'maxTrades', maxTrades);
        % Get index of winner and update win percentage
        [~, winPlayer] = max(vp(end, :));
        if winPlayer == numPlayers; winPercentage(rnd) = winPercentage(rnd) + 1/numTest; end
    end
    
    % Save the workspace after each round
    save(path + "round_" + string(rnd) + ".mat")
    
end

% Close waitbar
close(h);

end

