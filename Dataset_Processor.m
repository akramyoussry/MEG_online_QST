%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Datset_Processor.m: This file defines the function that processes the
% dataset by performing quantum state estimation for each true state given
% a particular scenario (qubit number / number of measurement shots). 
% Three estimators are used: Matrix Exponentiated Gradient, Diluted Maximum
% Likelihood, and Least-squares. The infidelity between the estimate at
% each iteration and the true state is calculated. The results are stored 
% in a .MAT file that includes the following records:
% * The MEG estimator object after finishing all iterations  
% * The ML estimator object after finishing all iterations
% * The LS estimator object after finishing all iterations
% * The infidelity record for the MEG estimator
% * The infidelity record for the ML estimator
% * The infidelity record for the LS estimator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Dataset_Processor(nExperiments , nQubits , idx_nShots, nIter)
% nExperiments  : Range of true states to process formatted as a row vector
% nQubits       : Number of qubits to simulate arranged in a row vector
% idx_nShots    : Index to the number of shots arranged in a row vector
% nIter         : Number of iterations (datapoints) for each case
%% Dataset Processing
fprintf('Starting the dataset processing\n')
% Loop over all possible scenarios (number of qubits / number of shots)
% To parallelize this loop, replace "for" with "parfor"
Cases  = [length(nExperiments) , length(idx_nShots) , length(nQubits) ];
nCases =  length(nExperiments) * length(idx_nShots) * length(nQubits);
for idx = 1:nCases
    % select a scenario 
    [i_State, i_nShots, i_nQubits] = ind2sub(Cases,idx);
    i_nQubits = nQubits(i_nQubits);
    i_nShots = idx_nShots(i_nShots);
    i_State = nExperiments(i_State);
    %% These initializations must be done in the beginning of each scenario
    % Define the number of dimensions of the quantum system
    dim=2^i_nQubits;
    % Generate the "up" and "down" projectors of the global Pauli operators
    % The function is defined externally in the file "Generate_Projectors.m"
    [Projectors_up, Projectors_down] = Generate_Projectors(i_nQubits);
    % Skip the first projector which is just a global identity operator
    Projectors_up = Projectors_up(2:end); 
    Projectors_down = Projectors_down(2:end); 
    % Define pauli basis for defining quantum state. This is just a
    % normalzied version of the pauli operators which can be expressed in
    % terms of the projectors as X = Pi_up - Pi_down
    Basis = cellfun(@(x,y) (x - y) / sqrt( trace( (x - y) * (x - y)') ),...
        Projectors_up, Projectors_down,'UniformOutput',0);
    % Initialize the infidelity record for each estimator. The record is
    % formatted as a matrix with rows corresponding to different true
    % states, and columns corresponding to the time iteration
    Infidelity_MEG=zeros(1,nIter);
    Infidelity_ML=zeros(1,nIter);
    Infidelity_LS=zeros(1,nIter);
    %%
    % Load an instance of the dataset
    Experiment = load(sprintf('.//%d_Qubits//Data//Experiment_%d.mat',i_nQubits,i_State));
    % Initialize Estimators
    MEG = MEG_Estimator(dim, Projectors_up);
    LS  = LS_Estimator(dim, [Projectors_up, Projectors_down], Basis );
    ML  = ML_Estimator(dim, [Projectors_up, Projectors_down],10);
    % Start the estimation iterations
    for iter=1:nIter
        % Select a random measurement operator (from the dataset)
        idx_pauli = Experiment.X(iter);
        % Simulate a measurement (from the dataset)
        nShots    = Experiment.nShots(i_nShots);
        n_up      = Experiment.n_up(i_nShots,iter);
        % Update estimators
        MEG       = MEG.update(idx_pauli, n_up, nShots ,0.5);
        LS        = LS.update(idx_pauli, n_up, nShots);
        ML        = ML.update(idx_pauli, n_up, nShots, 0.1);
        % Evaluate the infidelity with respect to the true state
        Infidelity_MEG(iter) = MEG.infidelity(Experiment.true_state);
        Infidelity_ML(iter)  = ML.infidelity(Experiment.true_state);
        Infidelity_LS(iter)  = LS.infidelity(Experiment.true_state);
    end
    % Export the data into a file with name in the form
    % "Experiment_n.mat" inside the folder "Results". This function is
    % defined later in this script.
    saveparfor(sprintf('.//%d_Qubits//Results//%d_nShots//Experiment_%d.mat',i_nQubits,i_nShots,i_State),MEG,ML,LS,Infidelity_MEG,Infidelity_ML,Infidelity_LS)
end
fprintf('Finished the dataset processing\n')
end
%%
% This function is for exporting the variables in an external file. It is
% defined in this 'dummy' way in order to provide support for parallel for
% loops because it is not possible to directly do file read and write
% operations in parfor loops.
function saveparfor(s, MEG, ML, LS,Infidelity_MEG,Infidelity_ML,Infidelity_LS)
save(s, 'MEG' , 'ML' , 'LS', 'Infidelity_MEG' ,'Infidelity_ML', 'Infidelity_LS')
end