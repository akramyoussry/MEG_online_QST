This is list of the files in the folder and their description:

-- DataSet_Generator.m: This file defines the function to generate the dataset for using with the quantum state estimation algorithm. 
The output for a single instance of the dataset is a .MAT file that includes the following records:
   *The Density matrix representing the true quantum state

   *The index of the measurement operator randomly selected each iteration (datapoint). The operators themselves can be generated from
    the function defined in "Generate_Projectors.m". The indices are formatted as a row vector of length equal to the number of iterations

   *The "up" outcome due to measurement at each iteration formatted as a matrix with rows corresponding to the different number of shots, and
    columns representing different time instants

   *The number of shots used in each setting formatted as a row vector

The files are arranged in the following folder structure:
    $current_path$-->1_qubits-->Data-->"Experiment_1.mat"
                                 -->"Experiment_2.mat"
                                 -->...etc.                      
                          -->Results-->1_nShots
                                    -->2_nShots
                                    ...etc.

               -->2_qubits-->Data-->"Experiment_1.mat"
                                 -->"Experiment_2.mat"
                                 -->...etc.                      
                          -->Results-->1_nShots
                                    -->2_nShots
                                    ...etc.
               ....etc.

The "Results" folder will be empty, but wll be filled later by the script "Dataset_Processor.m"

-- Datset_Processor.m: This file defines the function that processes the dataset by performing quantum state estimation for each true state given
a particular scenario (qubit number / number of measurement shots).  Three estimators are used: Matrix Exponentiated Gradient, Diluted Maximum
Likelihood, and Least-squares. The infidelity between the estimate at each iteration and the true state is calculated. The results are stored 
in a .MAT file that includes the following records:
 * The MEG estimator object after finishing all iterations  
 * The ML estimator object after finishing all iterations
 * The LS estimator object after finishing all iterations
 * The infidelity record for the MEG estimator
 * The infidelity record for the ML estimator
 * The infidelity record for the LS estimator
 
-- Datset_Postrocessor.m: This script generates the plots corresponding to the results obtained by running the script "Dataset_Processor.m". For 
each possible scenario (number of qubits/number of shots), the generated plots are the average infidelity versus number of iterations for each 
estimatoras well as the interquartile range plot for the average infdelity versus number of iterations for each estimator. The plots are 
then exported as .PNG and .EPS formats.

-- Example.m: This script is an example of generating the dataset and processing it to produce the results

-- OnlineEstimator.m: This file contains the definition of the base class of from which the other estimator classes are derived from.

-- ML_Estimator.m: This file contains the class definition of the diluted maximum likelihood estimator.

-- MEG_Estimator.m: This file contains the class definition of the Matrix exponentiated gradient estimator.

-- LS_Estimator.m: This file contains the class definition of the least-squares estimator.

--Generate_Projectors.m: This file contains the definition of the function that generates global Pauli operators acting on qubit systems of any 
 number of qubits, by tensoring local Pauli operators on individual qubits. Since all local Pauli's have two outcome "up/down" correpsonding to the
 +1/-1 eigenvalues, the global operators will have the same property. So, this function returns the two global projectors for "up/down" outcomes.