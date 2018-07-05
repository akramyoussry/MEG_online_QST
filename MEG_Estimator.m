%%
% MEG_Estimator.m: This file contains the class definition of the Matrix 
% exponentiated gradient estimator.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Declare the class inherited from the base class in "OnlineEstimator.m"
classdef MEG_Estimator < onlineEstimator
    %% The data members of the class
    properties
        Gt      % This is Gt of the update equation of MEG
        yt      % A row vctor for storing the outcomes for running average
        count   % A row vector for stroing the counts for running average
    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% The methods of the class     
    methods
        % Class constructor for initializing the data members, passes the
        % number of dimensions and the "up" measurement projectors
        function obj = MEG_Estimator(dim, projectors)
            % Call the base class constructor
            obj = obj@onlineEstimator(dim,projectors);
            % Initialize the class internal variables
            obj.Gt = logm(obj.estimate(:,:,1));
            obj.yt = zeros(1,length(projectors));
            obj.count = zeros(1,length(projectors));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The update rule for MEG. Overrides the base class update function       
        function obj = update(obj, i_direction, n_up, n_shots, eta)
            % call the base class update function
            obj = update@onlineEstimator(obj);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Convert from projectors to operators
            X = 2 * obj.projectors{i_direction} - eye(obj.dimension);
            y_actual = (2*n_up - n_shots)/n_shots;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Update measurement record
            obj.count(i_direction) = obj.count(i_direction) + 1;
            obj.yt(i_direction) = (...
            (obj.count(i_direction)-1) * obj.yt(i_direction) + y_actual...
                                    ) / obj.count(i_direction);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Construct the gradient of the loss function
            y_predict = trace(obj.estimate * X);
            grad_loss = 2*(y_predict - obj.yt(i_direction))*X;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Apply the MEG rule and update the estimate
            obj.Gt = obj.Gt - eta*grad_loss;
            estimate = expm(obj.Gt);
            obj.estimate = estimate/trace(estimate);
        end
    end
end