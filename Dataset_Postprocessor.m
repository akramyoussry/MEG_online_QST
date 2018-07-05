%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Datset_Postrocessor.m: This script generates the plots corresponding to
% the results obtained by running the script "Dataset_Processor.m". For 
% each possible scenario (number of qubits/number of shots), the generated 
% plots are the average infidelity versus number of iterations for each 
% estimatoras well as the interquartile range plot for the average
% infdelity versus number of iterations for each estimator. The plots are 
% then exported as .PNG and .EPS formats. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Dataset_Postprocessor(idx_Experiments, nQubits, idx_nShots, nIter)
% nExperiments  : Range of true states to process formatted as a row vector
% nQubits       : Number of qubits to simulate arranged in a row vector
% idx_nShots    : Index to the number of shots arranged in a row vector
% nIter         : Number of iterations (datapoints) for each case
%% Define some internal parameters
% Number of different scenarios
Cases = [length(nQubits) , length(idx_nShots)];
nCases = length(nQubits) * length(idx_nShots);
% indices to the quartiles:
quartiles = fix([0.25 , 0.5 , 0.75] * length(idx_Experiments));
%% Dataset Postprocessing
fprintf('Generating the plots\n')
% Loop over all possible scenarios (number of qubits / number of shots)
% To parallelize this loop, replace "for" with "parfor"
for idx = 1:nCases
    % select a scenario 
    [i_nQubits, i_nShots] = ind2sub(Cases,idx);
    i_nQubits = nQubits(i_nQubits);
    i_nShots = idx_nShots(i_nShots);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Combine the infidelities for all true states
    % Inititalize the infedlity record for each estimator.
    Infidelity_MEG = zeros(length(idx_Experiments),nIter);
    Infidelity_ML  = zeros(length(idx_Experiments),nIter);
    Infidelity_LS  = zeros(length(idx_Experiments),nIter);
    % Loop over all true states
    for i_State = idx_Experiments
        % Load the results of the state estimations procedures
        Results = load(sprintf('.//%d_Qubits//Results//%d_nShots//Experiment_%d.mat',i_nQubits,i_nShots,i_State));
        % Update the infidelity record for each state
        Infidelity_MEG(i_State,:) = Results.Infidelity_MEG;
        Infidelity_ML(i_State,:)  = Results.Infidelity_ML;
        Infidelity_LS(i_State,:)  = Results.Infidelity_LS;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Generate the average infedility versus iterations
    figure
    % average over all experiments
    Infidelity_MEG_avg = mean(Infidelity_MEG);
    Infidelity_ML_avg  = mean(Infidelity_ML);
    Infidelity_LS_avg  = mean(Infidelity_LS);
    % Plot the average infedility curves
    loglog(1:nIter,Infidelity_MEG_avg);
    hold on
    loglog(1:nIter,Infidelity_ML_avg);
    hold on
    loglog(1:nIter,Infidelity_LS_avg);
    % Add labels
    legend('MEG','ML','LS');
    xlabel('Iteration')
    ylabel('Infidelity');
    grid on
    % Export figure
    print(sprintf('.//%d_Qubits//Results//%d_nShots',i_nQubits,i_nShots),'-dpng');
    print(sprintf('.//%d_Qubits//Results//%d_nShots',i_nQubits,i_nShots),'-depsc');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Generate the interquartile range of infedlity versus iterations
    figure
    % Sort the infedilities to obtain the interquartiles
    Infidelity_MEG = sort(Infidelity_MEG);
    Infidelity_ML  = sort(Infidelity_ML);
    Infidelity_LS  = sort(Infidelity_LS);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get the interquartiles for ML
    curve_25 = Infidelity_ML(quartiles(1),:);
    curve_50 = Infidelity_ML(quartiles(2),:);
    curve_75 = Infidelity_ML(quartiles(3),:);
    % Plot the borders
    loglog(1:nIter,curve_25,'b',1:nIter,curve_75,'b');
    % Fill in between the borders to produce the range plot
    x2 = [1:nIter,fliplr(1:nIter)];
    inbetween = [curve_25, fliplr(curve_75)];
    hold on
    fill(x2,inbetween,'g','FaceAlpha',0.3)
    % Plot the median line
    hold on
    h1 = loglog(1:nIter,curve_50,'k','LineWidth',2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get the interquartiles for MEG
    curve_25 = Infidelity_MEG(quartiles(1),:);
    curve_50 = Infidelity_MEG(quartiles(2),:);
    curve_75 = Infidelity_MEG(quartiles(3),:);
    % Plot the borders
    hold on
    loglog(1:nIter,curve_25,'b',1:nIter,curve_75,'b');
    % Fill in between the borders to produce the range plot
    x2 = [1:nIter,fliplr(1:nIter)];
    inbetween = [curve_25, fliplr(curve_75)];
    hold on
    fill(x2,inbetween,'y','FaceAlpha',0.3)
    % Plot the median line
    hold on
    h2 = loglog(1:nIter,curve_50,'--k','LineWidth',2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get the interquartiles for LS
    curve_25 = Infidelity_LS(quartiles(1),:);
    curve_50 = Infidelity_LS(quartiles(2),:);
    curve_75 = Infidelity_LS(quartiles(3),:);
    % Plot the borders
    hold on
    loglog(1:nIter,curve_25,'b',1:nIter,curve_75,'b');
    % Fill in between the borders to produce the range plot
    x2 = [1:nIter,fliplr(1:nIter)];
    inbetween = [curve_25, fliplr(curve_75)];
    hold on
    fill(x2,inbetween,'k','FaceAlpha',0.3)
    % Plot the median line
    hold on
    h3 = loglog(1:nIter,curve_50,':k','LineWidth',2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add labels
    xlabel('Iteration')
    ylabel('Infidelity');
    grid on
    legend([h1 h2 h3],{'ML','MEG','LS'})
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Export figure
    print(sprintf('.//%d_Qubits//Results//stats_%d_nShots',i_nQubits,i_nShots),'-dpng');
    print(sprintf('.//%d_Qubits//Results//stats_%d_nShots',i_nQubits,i_nShots),'-depsc');
end
close all
fprintf('Finished the dataset postprocessing\n')