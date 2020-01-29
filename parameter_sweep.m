clc
clear all
close all



%% Define parameter ranges
% General parameters
params = struct;
params.verbose = 1; % 1 to activate informational display; 0 to deactivate
params.vol_viewer = 'volume_viewer'; % defines the type of volume viewer to be used; change to 'pcshow' if point cloud is desired
params.stl_filename = 'Radial_circum_vert.stl';
% params.target_3D ; % use this to directly define the 3D target matrix
params.resolution = 100; % number of voxels in the dimension of minimum length
params.angles = {0:1:179,0:0.5:179.5,0:0.25:179.75}; % vector of real angles of projection; should be [0-180 deg]
params.parallel = 0; % 1 to activate parallel computing; 0 to deactivate; require Parallel Computing toolbox

% Optimization parameters
params.learningRate = 0.001:0.002:0.02; % Relaxation parameter: how far along do we move in the Newton iteration
params.Rho = 0.01; % Robustness parameter
params.Theta = 0.2; % Hybrid input-output parameter; Theta = 0 corresponds to perfect constraint
params.Beta = 0.85; % Memory Effect - how much of the previous iteration error is used in computing the current iteration update; Beta = 0 corresponds no memory
params.sigmoid = 2;
params.sigma_init = 2;
params.sigma_end = 1.0;
params.max_iterations = 10:5:60;
% params.tol; % use this to set the error tolerance of optimization


% Sweep parameters
params_sweep.learningRate = 0.001:0.002:0.02;
params_sweep.angles = {0:1:179,0:0.5:179.5,0:0.25:179.75};
params_sweep.max_iterations = 10:5:60;
save_path = 'ParameterSweep';

%% 

[target,target_care_area] = voxelize_target(params); % prepare target 

counter = 1;

for kk = 1:size(params_sweep.angles,2)
    params.angles = params_sweep.angles{kk};
    
    for jj = 1:length(params_sweep.learningRate)
        params.learningRate = params_sweep.learningRate(jj);
        
        for ii = 1:length(params_sweep.max_iterations)
            params.max_iterations = params_sweep.learningRate(ii);
            
            projections = initialize_projections(params,target); % create initial guess of projections
            
            [optimized_projections,error,thresholds] = optimize_projections(params,projections,target,target_care_area); % optimize projections to minimize error between target and reconstruction  
            
            
            
            dir_name = sprintf('%2.0d',counter);
            filename = fullfile(save_path,dir_name);
            mkdir(filename)
                    
            save logvariables.mat
        
        
        end % ii
    
    end % jj

end %kk
        