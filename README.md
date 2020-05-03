# Training an Autonomous Agent to Play Settlers of Catan using Reinforcement Learning

## Introduction

The core of this software package is a MATLAB-based simulator which runs Monte Carlo simulations of games of Settlers of Catan. Initially, this Monte Carlo simulator chooses actions at each turn by selecting a board state at random from the set of possible board states based on the player's available moves. During training, the simulator may instead select actions using an epsilon-greedy policy based on a learned quality function. This quality function may be learned in an unsupervised manner by having the computer play games against itself, using the data obtained from these simulations to further refine the quality function.

## How to Use

Monte Carlo simulations may be run using the function `utils.runMonteCarlo()`, while model training and testing may be performed using the function `utils.trainModel()`. The `utils` package contain helper functions for model training and testing, and various member functions of user-defined classes. For additional information on calling each function, use the MATLAB `help` function followed by the function name (e.g. `help utils.trainModel`).

The `Classes` folder contains various user-defined classes (and enumerations) important for defining the game board. The most notable of these is the `Board` class, which contains properties and methods related to the game board and bank, as well as enabling basic moves and transactions. More information on each class and enumeration may be found in the main file (e.g. `Board.m`).

![Image](https://i.imgur.com/Ji1fG7q.png)
|:--:| 
| Example result of running `utils.runMonteCarlo()`. |

## Monte Carlo Simulator

Monte Carlo simulations may be run using the function `utils.runMonteCarlo()`, which initializes a random game board with up to six players. The above example shows the results of running a Monte Carlo simulation with three players and a random policy. In the graphical representation, circles and squares on nodes represent settlements and cities respectively, with colored edges representing roads. The neural networks describing the quality function used by each player may be passed as an argument to this function.

## Model Training and Testing

The function `utils.trainModel()` handles training and testing of quality functions learned via Monte Carlo simulations. Training and testing is split into rounds of a specified number of games each. In the first round, a random policy is used to generate moves for each player; each move is associated with the victory point count achieved by the player at the end of the game. Upon training the neural network-based quality function in the first round, network weights are refined after each round of training by generating samples using Monte Carlo simulation with the learned quality function and an epsilon-greedy policy. The quality function input is a vector-based interpretation of the overall board state (from the perspective of each particular player), with the target output being the ultimate victory points achieved from the board state.

This function returns the trained quality function, win percentage of the model against a random policy at each round, and the data generated during training.
