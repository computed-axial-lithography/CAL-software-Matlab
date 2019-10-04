%% Main code


%% Clean workspace
clc
clearvars
close all

%% Input parameters

% General parameters
verbose = 1; % 1 to activate informational display; 0 to deactivate
params = struct;
params.stl_filename = 'U_tube.stl';
params.resolution = 40;
params.angles = 0:0.5:180;
params.parallel = 0; % 1 to activate parallel computing; 0 to deactivate; require Parallel Computing toolbox

% Optimization parameters
params.learningRate = 0.03; % Relaxation parameter: how far along do we move in the Newton iteration
params.Rho = 0.01; % Robustness parameter
params.Theta = 0.2; % Hybrid input-output parameter; Theta = 0 corresponds to perfect constraint
params.Beta = 0.85; % Memory Effect - how much of the previous iteration error is used in computing the current iteration update; Beta = 0 corresponds no memory
params.sigma_init = 1.0;
params.sigma_end = 1.0;
params.max_iterations = 40;

%% Begin optimization
[target,target_care_area] = voxelize_target(params,verbose); % prepare target 

projections = initialize_projections(params,target,verbose); % create initial guess of projections

[optimized_projections,error] = optimize_projections(params,projections,target,target_care_area,verbose); % optimize projections to minimize error between target and reconstruction  

show_projections(optimized_projections) % display projections


