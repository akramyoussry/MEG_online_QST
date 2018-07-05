%%
% ML_Estimator.m: This file contains the class definition of the diluted
% maximum likelihood estimator.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Declare the class inherited from the base class in "OnlineEstimator.m" 
classdef ML_Estimator < onlineEstimator
    %% The data members of the class
    properties
        Record          % A row vector storing outcomes of all measurements
        N_Measurements  % The total number of measurements performed so far
        max_iter        % Maximum number of internal ML iterations
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% The methods of the class    
    methods
        % Class constructor for initializing the data members, passes the
        % number of dimensions and the measurement projectors (both up and
        % down projectors must be passed as one concatenated cell array)
        function obj = ML_Estimator(dim, projectors, max_iter)
            % Calcuate the number of "up" projectors only
            l = length(projectors)/2;
            % Convert the projectors to POVMs by normalization
            POVM = cellfun(@(x)x/l,projectors,'UniformOutput',0);
            % Call the base class constructor
            obj = obj@onlineEstimator(dim,POVM);
            % Initialize the class internal variables
            obj.Record = zeros(1,length(projectors));
            obj.N_Measurements = 0;
            obj.max_iter = max_iter;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The update rule for ML. Overrides the base class update function
        function obj = update(obj, i_direction, n_up, n_shots, epsilon)
            % call the base class update function
            obj = update@onlineEstimator(obj);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Update measurement record
            % 1) Calcuate the number of "up" projectors only
            l = length(obj.projectors)/2;
            % 2) Update the "up" outcome corresponding to the mesurement 
            %     operator selected at the current iteration           
            obj.Record(i_direction) = obj.Record(i_direction) + n_up;
            % 3) Update the "down" outcome corresponding to the mesurement 
            %     operator selected at the current iteration 
            obj.Record(i_direction + l) = obj.Record(i_direction + l) + ...
                                                          (n_shots - n_up);
            % 4) Update the total number of measurements
            obj.N_Measurements = obj.N_Measurements + n_shots;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Start internal iterations of the ML method:
            % Define identity matrix
            I = eye(obj.dimension);
            % Initialize the estimate
            estimate = obj.estimate;
            % Loop over internal iteations
            for internal_iter = 1:obj.max_iter
                % Caluclare R variable: R = \Sum_j(Pi(j)*f(j)/N*prob(j))
                R = 0;
                for idx_dir = 1:length(obj.projectors)
                    Prob=trace(estimate*obj.projectors{idx_dir});
                    R = R + ...
                       ( obj.Record(idx_dir) * obj.projectors{idx_dir} /...
                           (obj.N_Measurements*Prob) );
                end               
                % Diluted version of ML update rule:
                R = (R - I);
                estimate = (I+epsilon*R) * estimate * (I+epsilon*R');
                estimate = sqrtm(estimate*estimate');
                estimate = estimate/trace(estimate);              
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Update the estimate after finishing the internal iterations
            obj.estimate = estimate;
        end
    end
end