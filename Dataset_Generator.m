%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DataSet_Generator.m: This file defines the function to generate the 
% dataset for using with the quantum state estimation algorithm. 
% The output for a single instance of the dataset is a .MAT file that 
% includes the following records:

%   *The Density matrix representing the true quantum state

%   *The index of the measurement operator randomly selected each
%    iteration (datapoint). The operators themselves can be generated from
%    the function defined in "Generate_Projectors.m". The indices are
%    formatted as a row vector of length equal to the number of iterations

%   *The "up" outcome due to measurement at each iteration formatted as a
%    matrix with rows corresponding to the different number of shots, and
%    columns representing different time instants

%   *The number of shots used in each setting formatted as a row vector

% The files are arranged in the following folder structure:
% $current_path$-->1_qubits-->Data-->"Experiment_1.mat"
%                                 -->"Experiment_2.mat"
%                                 -->...etc.                      
%                          -->Results-->1_nShots
%                                    -->2_nShots
%                                    ...etc.
%
%               -->2_qubits-->Data-->"Experiment_1.mat"
%                                 -->"Experiment_2.mat"
%                                 -->...etc.                      
%                          -->Results-->1_nShots
%                                    -->2_nShots
%                                    ...etc.
%               ....etc.
% The "Results" folder will be empty, but wll be filled later by the script
% "Dataset_Processor.m"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Dataset_Generator(nExperiments, nQubits, nShots, nIter)
% nExperiments    : Number of generated true states
% nQubits         : Number of qubits to simulate arranged in a row vector
% nShots          : Number of shots to simulate arranged in a row vector
% nIter           : Number of iterations (datapoints) for each case
%% Dataset Generation
fprintf('Starting the dataset generation\n')
% Loop over the number  of qubits to simulate as specified by the user
% To parallelize this loop, replace "for" with "parfor"
for idx = 1:length(nQubits)
    i_nQubits = nQubits(idx);
    fprintf('\nGenerating the data for %d qubits\n',i_nQubits);
    % Make new folders for this qubit case, if it doesn't already exist
    if( ~exist( sprintf('.//%d_Qubits//Data',i_nQubits) , 'dir') )
        mkdir(sprintf('.//%d_Qubits//Data',i_nQubits));
    end
    for i_nShots = 1:length(nShots)
        if( ~exist( sprintf('.//%d_Qubits//Results//%d_nShots',i_nQubits,i_nShots) , 'dir') )
            mkdir(sprintf('.//%d_Qubits//Results//%d_nShots',i_nQubits,i_nShots));
        end
    end
    % Initialize the matrix for "up" outcomes
    n_up = zeros(length(nShots),nIter);
    % Define the number of dimensions of the quantum system
    dim = 2^i_nQubits;
    % Define the identity matrix
    I = eye(dim);
    % Generate the "up" projectors of the global Pauli operators. The
    % function is defined externally in the file "Generate_Projectors.m"
    [Projectors_up, ~] = Generate_Projectors(i_nQubits);
    % Skip the first projector which is just a global identity operator
    Projectors_up = Projectors_up(2:end);
    % Loop over the number of true states as specified by the user
    for i_Run = 1:nExperiments
        % Generate a random complex matrix of correct dimensions
        A = rand(dim)+1j*rand(dim);
        % Modify the matrix to represent a physical quantum state
        true_state = A*A'/trace(A*A');
        % Generate a random row vector representing the Pauli indices which 
        % has length equal to the number of iterations (datapoints) as
        % specified by the user. Each element lies in the range specified
        % by the number of available projectors 
        X = randi(length(Projectors_up),1,nIter);
        % Simulate the measurement for each selected operator using 
        % different number of shots as specified by the user
        for iter=1:nIter %Loop over the number of iterations (datapoints)        
            % Select the projector generated at the current datapoint
            PI = Projectors_up{X(iter)}; 
            % Loop over different number of shots
            for i_nShots = 1:length(nShots)      
               % Generate a binomail distributed random variable with
               % number of trials equal to the number of shots, and
               % probability \tr(\rho \Pi), and fill in the matrix           
               n_up( i_nShots , iter ) = binornd( nShots(i_nShots),...
                   real( trace( true_state *PI ) ) );
            end
        end
        % Export the data into a file with name in the form
        % "Experiment_n.mat" inside the folder "Data". This function is
        % defined later in this script.
        saveparfor(sprintf('.//%d_Qubits//Data//Experiment_%d.mat',...
                    i_nQubits,i_Run),true_state, X , n_up , nShots);
    end
end
fprintf('\nFinsihed the dataset generation\n'); 
end
%% 
% This function is for exporting the variables in an external file. It is
% defined in this 'dummy' way in order to provide support for parallel for
% loops because it is not possible to directly do file read and write
% operations in parfor loops.
function saveparfor(s, true_state, X , n_up , nShots)
save(s,'true_state','X','n_up','nShots')
end