cd ..;
addpath('Examples')


clear all
close all

% set projection parameters
proj_params.angles = linspace(0,179,180);

% set optimization parameters
opt_params.max_iter = 40;
opt_params.threshold = 0.85;

verbose = 1;

% create an example 3D target
target_3D = createTarget(201,'L',3);

% prepare the target
target_obj = CALPrepTarget([],[],verbose,target_3D);

% instantiate the optimization class
Opt = CALOptimize(target_obj,opt_params,proj_params,verbose);

% run the optimization
[proj_obj,recon_obj,Opt] = Opt.run();




cd 'Examples';




