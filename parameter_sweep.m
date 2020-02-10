clc
clear all
close all



%% Define parameter ranges
% General parameters
params = struct;
params.verbose = 1; % 1 to activate informational display; 0 to deactivate
params.vol_viewer = 'pcshow'; % defines the type of volume viewer to be used; change to 'pcshow' if point cloud is desired
params.stl_filename = 'Radial_circum_vert.stl';
% params.target_3D ; % use this to directly define the 3D target matrix
params.resolution = 80; % number of voxels in the dimension of minimum length
params.angles = 0:1:179; % vector of real angles of projection; should be [0-180 deg]
params.parallel = 0; % 1 to activate parallel computing; 0 to deactivate; require Parallel Computing toolbox

% Optimization parameters
params.learningRate = 0.001; % Relaxation parameter: how far along do we move in the Newton iteration
params.Rho = 0.01; % Robustness parameter
params.Theta = 0.2; % Hybrid input-output parameter; Theta = 0 corresponds to perfect constraint
params.Beta = 0.85; % Memory Effect - how much of the previous iteration error is used in computing the current iteration update; Beta = 0 corresponds no memory
params.sigmoid = 1;
params.sigma_init = 2;
params.sigma_end = 1.0;
params.max_iterations = 25;
% params.tol; % use this to set the error tolerance of optimization


% Sweep parameters
params_sweep.learningRate = 0.001:0.01:0.08;
% params_sweep.angles = {0:1:179,0:0.5:179.5,0:0.25:179.75};
params_sweep.max_iterations = 10:10:60;
params_sweep.Beta = 0:0.2:1;
params_sweep.Theta = 0:0.2:1;
params_sweep.sigma_init = 1:2:10;
save_path = 'ParameterSweep';

%% 

[target,target_care_area] = voxelize_target(params); % prepare target 

counter = 1;

for kk = 1:length(params_sweep.Beta)
    params.Beta = params_sweep.Beta(kk);
    
    for jj = 1:length(params_sweep.Theta)
        params.Theta = params_sweep.Theta(jj);
        
        for ii = 1:length(params_sweep.learningRate)
            params.learningRate = params_sweep.learningRate(ii);
            
            fprintf('Beta = %0.3f  Theta = %0.3f Learning Rate = %0.3f\n',params.Beta,params.Theta,params.learningRate)
            
            
            tic
            projections = initialize_projections(params,target); % create initial guess of projections
            
            [optimized_projections,error,thresholds] = optimize_projections(params,projections,target,target_care_area); % optimize projections to minimize error between target and reconstruction  
            rutime = toc;
            

            % Setup directory for saving variables and figure images
            dir_name = sprintf('%2.0d',counter);
            filename = fullfile(save_path,dir_name);
            mkdir(filename)
            save_path_vars = fullfile(save_path,dir_name,'logvariables.mat');        
            
            save(save_path_vars) % save all variables in workspace
            
            
            fig_list = findobj(allchild(0),'flat','Type','figure');
            
            for ifig = 1:length(fig_list)
                fig_handle = fig_list(ifig);
                fig_name = get(fig_handle,'Name');
                fig_filename = fullfile(save_path,dir_name,fig_name);
                saveas(fig_handle,fig_filename,'png'); % save all figures as images
            end
            
            % Close all figures except for voxelized target figure
            close(2)
            close(3)
            counter = counter + 1;
        end % ii
    
    end % jj

end %kk
        