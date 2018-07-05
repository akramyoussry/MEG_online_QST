%%
% LS_Estimator.m: This file contains the class definition of the least-
% squares estimator.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Declare the class inherited from the base class in "OnlineEstimator.m"
classdef LS_Estimator < onlineEstimator
    %% The data members of the class
    properties
        Basis   % The basis to represent a quantum state 
        X       % The expansion of the projectors in terms of the basis
        XInv    % This represents inv(X'X)X'
        Theta   % The estimated parameter representing the quantum state
        Record  % A column vector representing the outcomes of measurements
        Counts  % A column vector representing the counts of measurements
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% The methods of the class      
    methods
        % Class constructor for initializing the data members, passes the
        % number of dimensions, the measurement projectors (both up and
        % down projectors must be passed as one concatenated cell array),
        % and the basis for respresenting the qantum states
        function obj = LS_Estimator(dim, Projectors, Basis)
            % Call the base class constructor
            obj = obj@onlineEstimator(dim,Projectors);
            % Initialize the measurment records to have initial probaility
            % equal to 1/2, until we have enough measurements
            obj.Record = ones(length(Projectors),1);
            obj.Counts = 2*ones(length(Projectors),1);
            % Expand the projectors in terms of the basis to obtain the X
            % matrix to be used in the LS estimation rule
            obj.Basis = Basis;
            for i=1:length(Projectors)
                for j=1:length(Basis)
                    obj.X(i,j) = trace(Projectors{i}*Basis{j}');
                end
            end
            % Precompute the matrix inverse
            obj.XInv = inv(obj.X'*obj.X)*obj.X';
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The update rule for LS. Overrides the base class update function
        function obj = update(obj, i_direction, n_up , n_shots)
            % call the base class update function
            obj = update@onlineEstimator(obj);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Update measurement records
            % 1) Calcuate the number of "up" projectors only
            l = size(obj.X,1)/2;
            % 2) Update the "up" outcome corresponding to the mesurement 
            %     operator selected at the current iteration  
            obj.Record(i_direction) = obj.Record(i_direction) + n_up;
            % 3) Update the "down" outcome corresponding to the mesurement 
            %     operator selected at the current iteration 
            obj.Record(i_direction + l ) = obj.Record(i_direction + l) +...
                                                          (n_shots - n_up);
            % 4) Update the measurement counts for "up" and "down" outcomes
            obj.Counts(i_direction) = obj.Counts(i_direction) + n_shots;
            obj.Counts(i_direction + l) = obj.Counts(i_direction + l) + n_shots;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Apply the LS rule: theta = inv(X'X)X'Y
            Y = ( (obj.Record./obj.Counts) - (1/obj.dimension) );
            obj.Theta = obj.XInv*Y;
            % Use the estimate to construct a non-physical quantum state
            rho_unphy = eye(obj.dimension)/obj.dimension;
            for i=1:length(obj.Basis)
                rho_unphy = rho_unphy + obj.Theta(i)*obj.Basis{i};
            end
            % Project the unphysical state to a physical state, then update
            % the estimate
            obj.estimate = obj.project(rho_unphy);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % function to project a non-physical state to a physical state by
        % redistributing negative eigenvalues over all positive eigenvalues
        % in order. The input must be Hermitian for the algorithm to work
        function rho_phy = project(obj,rho_unphy)
            % Eigenvalue decomposition of the non-physical state sorted in
            % descending order
            [Q,D] = eig(rho_unphy);
            [mu,I] = sort(diag(D),'descend');
            Q = Q(:,I);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Initialize the vector of new eigenvalues of the phyical state
            lambda = mu;
            % loop over eigenvalues from least value (most non-negative to
            % the largest value)
            a = 0;
            for i = obj.dimension:-1:1
                % check if we need to set this eigenvalue to zero and then
                % redistribute it over other eigenvalues
                if (mu(i) + (a/i)) < 0
                    lambda(i) = 0;
                    a = a + mu(i);
                else
                %stop the loop once we hit a positive eigenvalue 
                    break;
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % loop over all positves eigenvalues and add the negative ones
            for j=1:i
                lambda(j) = mu(j) + (a/i);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Reconstruct the state 
            rho_phy = Q * diag(lambda) * Q';
        end
    end
end