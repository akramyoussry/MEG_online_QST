%% 
% OnlineEstimator.m: This file contains the definition of the base class of
% from which the other estimator classes are derived from.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Declare the class
classdef onlineEstimator
    %% The data members of the class
    properties
        dimension   % The number of dimensions (size of the density matrix)
        projectors  % A cell array containing all measurement projectors
        estimate    % The estimate of the quantum state
        iter        % The current iteration number
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% The methods of the class
    methods       
        % Class constructor for initializing the data members, passes the
        % number of dimensions and the measurement projectors
        function obj = onlineEstimator(dim,projectors)
            if nargin>0 %No Input Argument Constructor Requirement (MATLAB)
                obj.dimension = dim;
                obj.projectors = projectors;
                obj.estimate = eye(dim)/dim; %Mixed state
                obj.iter = 0;
            end
        end
        
        % Abstraction for estimate update. Override for inherited classes
        function obj = update(obj)
            obj.iter = obj.iter + 1; %increment the number of iterations
        end
        
        % Calculate the fidelity given a true quantum state
        function f = fidelity(obj, true_state)
            f = obj.trace_norm( sqrtm(obj.estimate)*sqrtm(true_state) )^2;
        end
        
        % Calculate the infidelity given a true quantum state
        function f = infidelity(obj,true_state)
            f = 1 - obj.trace_norm( sqrtm(obj.estimate)*sqrtm(true_state) )^2;
        end
        
        % Calculate the frobenius distance between the estimate and a given 
        % true quantum state
        function delta = frobenius_distance(obj,true_state)
            delta = norm(obj.estimate - true_state, 'fro');
        end
        
        % Calculate the trace distance between the estimate and a given
        % true quantum state
        function delta = trace_distance(obj,true_state)
            delta = 0.5 * trace_norm(obj.estimate - true_state);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% A ststic function for defining trace norm
    methods(Static)
        function delta = trace_norm(rho)
            delta = real( trace( sqrtm(rho*rho') ) );
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end