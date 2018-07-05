%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate_Projectors.m: This file contains the definition of the function
% that generates global Pauli operators acting on qubit systems of any 
% number of qubits, by tensoring local Pauli operators on individual qubits. 
% Since all local Pauli's have two outcome "up/down" correpsonding to the
% +1/-1 eigenvalues, the global operators will have the same property. In
% many cases, the projectors of the operators are required, which is more
% difficult to caclulate than having projectors and construct the operator
% from them. So, this function returns two cell arrays containing the
% global projectors for "up/down" outcomes. The first element in the cell
% will always be the Identity, which is not usually used. The algorithm to
% generate these projectors simply to use the fact that the projectors of
% any 1-qubit pauli operator is in the form 0.5(I+X) or 0.5(I-X), where X
% can be I,sigma_x,sigma_y,sigma_z. This means we have three degrees of
% freedom: the qubit number, the local pauli of this qubit, and the outcome
% (up/down). The direction of the global Pauli operator is determined by
% the choice of the direction at qubit, while the outcome of each global
% operator is determined by the local outcomes. So, after fixing a certain
% global direction, all local projectors are calculated then tensored, then
% combined to form two global projectors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Projector_Positive, Projector_Negative] = Generate_Projectors(n_qubits)
% number of global operators:
n_directions = (2^n_qubits)^2 ;
% number of local outcomes [each qubit in any direction can be up/down]:
n_outcomes = (2^n_qubits) ;
% Pauli matrices for a single qubit:
Sigma={[1 0;0 1], [0 1;1 0],[0 -1i;1i 0],[1 0;0 -1]};
% 2x2 identitiy matrix: 
I=eye(2);
% Initialize the cell arrays for the global Pauli projectors:
Projector_Positive = cell(1,n_directions); 
Projector_Negative = cell(1,n_directions); 
% Loop over all possible directions
for i_direction=0:n_directions-1
    %select a direction and represent it in base 4 to be able to select
    %the proper local pauli matrix
    direction = dec2base(i_direction,4,n_qubits);
    
    %Initialize the global projectors for this direction
    Projector_Positive{i_direction+1}=zeros(n_outcomes);
    Projector_Negative{i_direction+1}=zeros(n_outcomes);
    
    %loop over the number of outcomes per each direction
    for i_outcome=0:n_outcomes-1
        % Select an outcome and represent it as binary to be able to select
        %the proper local outcome (up or down)
        outcome = dec2base(i_outcome,2,n_qubits);
        
        % Initialize a projector
        Projector_local=1;
        
        % Loop locally over all qubits
        for i_qubit=1:n_qubits
            % Select a local pauli matrix
            idx_pauli = str2num(direction(i_qubit))+1;
            X=Sigma{idx_pauli};
            % Select a local outcome [up --> 0 --> + / down --> 1 --> -]
            sign=(-1)^str2num(outcome(i_qubit));
            % Check if it is a Pauli or identity, because in the case of
            % identity we need to fix the eigendecomposition 0.5(I+Z) not
            % 0.5(I+I), and also in this case the qubit doesn't affect hte
            % global outcome, because physically idenitity means we are not
            % measuring it at all, so the outcome of the global measurement
            % depends only on the other qubits.
            if idx_pauli~=1
                % Tensor to the other local projectors we have so far
                Projector_local = kron(Projector_local, 0.5 * (I + sign*X) );
            else %if it is identity
                % Tensor to the other local projectors we have so far
                Projector_local = kron(Projector_local, 0.5 * (I + sign*Sigma{4}));
                % Enforce the eignevalues of I to be positve (up) (0)
                outcome(i_qubit) = '0'; 
            end
        end
        
        % Check whether the otucome corresponds to the global positive or
        % negative subspace to construct the global projector for this
        % direction
        if mod(sum(outcome),2)==0 % Even number of binary 1s (pos outcome)
            Projector_Positive{i_direction+1} = Projector_Positive{i_direction+1} + Projector_local; 
        else % Odd number of binary 1s (neg. outcome)
            Projector_Negative{i_direction+1} = Projector_Negative{i_direction+1} + Projector_local; 
        end
    end
end

% This is a verification step, if something goes wrong a message dsiplays
% with the failed test, othersise nothing is displayed.
for i_direction=1:n_directions
    % Sum = 1 (Span the whole global subspace)
    if(~isequal(Projector_Positive{i_direction}+Projector_Negative{i_direction},eye(n_outcomes)))
        fprintf('error in spanning condition at direction %d\n',i_direction)
    end
    % Pi_+ Pi_- = 0 (Orthogonal)
    if(~isequal(Projector_Positive{i_direction}*Projector_Negative{i_direction},zeros(n_outcomes)))
        fprintf('error in orhtogonality condition at direction %d\n',i_direction)
    end
    % Pi=Pi' (Hermitian)
    if(~isequal(Projector_Positive{i_direction},Projector_Positive{i_direction}') || ~isequal(Projector_Negative{i_direction},Projector_Negative{i_direction}'))
        fprintf('error in Heremticitiy condition at direction %d\n',i_direction)
    end
    % Pi^2=Pi (Projectors)
    if(~isequal(Projector_Positive{i_direction},Projector_Positive{i_direction}^2) || ~isequal(Projector_Negative{i_direction},Projector_Negative{i_direction}^2))
        fprintf('error in projectivity condition at direction %d\n',i_direction)
    end
end