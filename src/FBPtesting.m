clear all
close all

%%%%%%%%%%%%%  Projection generation and optimization  %%%%%%%%%%%%%
% set projection parameters
proj_params.angles = linspace(0,359,360);
proj_params.bit8 = 0;


% set optimization parameters
opt_params.optimizer = 'FBP';

verbose = 1;

resolution = 200;
stl_filename = 'Examples\bear.stl';
target_obj = CALPrepTarget(stl_filename,resolution,verbose);
% target_2D = target_obj.target(:,:,50);% prepare the target
% target_obj = CALPrepTarget([],[],verbose,target_2D);
% instantiate the optimization class
Opt = CALOptimize(target_obj,opt_params,proj_params,verbose);

% run the optimization
[proj_obj,recon_obj,Opt] = Opt.run();