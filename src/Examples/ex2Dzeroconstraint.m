cd ..;
addpath('Examples')

clear all
close all

% set projection parameters
proj_params.angles = linspace(0,179,180);
proj_params.zero_constraint = true;
% proj_params.bit8 = 0;


% set optimization parameters
opt_params.max_iter = 25;
opt_params.threshold = 0.85;
opt_params.learning_rate = 0.1;
% opt_params.filter = false;

verbose = 1;


% create an example 2D target
target_2D = createTarget(201,'tube',2);

% prepare the target
target_obj = CALPrepTarget([],[],verbose,target_2D);

% instantiate the optimization class
Opt = CALOptimize(target_obj,opt_params,proj_params,verbose);

% run the optimization
[proj_obj,recon_obj,Opt] = Opt.run();



cd 'Examples';