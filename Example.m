%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example.m: This script is an example of generating the dataset and
% processing it to produce the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% clear the command window, close any figure, and clear the workspace 
clc
close all
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Dataset Generation
% Number of generated true states:
idx_Experiments = 20;
% Number of qubits to simulate arranged in a row vector:
nQubits = [1,2,3,4]; 
% Number of shots to simulate arranged in a row vector:
nShots = [10,100,1000,10000]; 
%Number of iterations (datapoints) for each case:
nIter = 10^2; 
% Generate the Dataset
Dataset_Generator(idx_Experiments, nQubits, nShots, nIter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Dataset Processing
% Range of true states to process formatted as a row vector:
idx_Experiments = [1:10, 14:20];
% Number of qubits to simulate arranged in a row vector:
nQubits = [1,2,4]; 
% Number of shots to simulate arranged in a row vector:
idx_nShots = [1,2,3,4]; 
%Number of iterations (datapoints) for each case:
nIter = 10^2; 
% Process the Datset
Dataset_Processor(idx_Experiments, nQubits, idx_nShots, nIter)
% Produce the plots
Dataset_Postprocessor(idx_Experiments, nQubits, idx_nShots, nIter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%