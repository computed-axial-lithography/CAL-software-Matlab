cd ..;
addpath('Examples')



clear all
close all

% set projection parameters
proj_params.angles = linspace(0,179,180);
proj_params.bit8 = 1;

% set optimization parameters
opt_params.max_iter = 40;
opt_params.threshold = 0.8;
opt_params.learning_rate = 0.005;

verbose = 1;

% prepare the target
resolution = 140;
stl_filename = loadExStlFilename('bear');
target_obj = CALPrepTarget(stl_filename,resolution,verbose);

% instantiate the optimization class
Opt = CALOptimize(target_obj,opt_params,proj_params,verbose);

% run the optimization
[proj_obj,recon_obj,Opt] = Opt.run();






cd 'Examples';
