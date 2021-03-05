cd ..;
addpath('Examples')


clear all
close all

%%%%%%%%%%%%%  Projection generation and optimization  %%%%%%%%%%%%%
% set projection parameters
proj_params.angles = linspace(0,179,180);
proj_params.bit8 = 1;

% set optimization parameters
opt_params.max_iter = 50;
opt_params.threshold = 0.8;
opt_params.learning_rate = 0.005;

verbose = 1;

% prepare the target
resolution = 140;
stl_filename = loadExStlFilename('bear'); % acceptable inputs 'bear', 'thinker', 'octet', 'octahedron'
target_obj = CALPrepTarget(stl_filename,resolution,verbose);

% instantiate the optimization class
Opt = CALOptimize(target_obj,opt_params,proj_params,verbose);

% run the optimization
[proj_obj,recon_obj,Opt] = Opt.run();

%%%%%%%%%%%%%  Image set creation  %%%%%%%%%%%%%
% set the desired image modifiers
image_params.size_scale_factor = 2;
image_params.invert_vert = 1;
image_params.image_width = 1920; % this parameter should be changed to match your projector image, default is 1920
image_params.image_height = 1080; % this parameter should be changed to match your projector image, default is 1080

C = CALCreateImageSet(proj_obj,image_params);

% create the image set
image_set_obj = C.run();

%%%%%%%%%%%%%  Image sequence projection  %%%%%%%%%%%%%
% set the rotation velocity in deg/s
rot_vel = 24;

% set the monitor ID
monitor_id = 2;

% set whether the screen projects a black screen when projection is paused
blank_when_paused = 1;

% initialize the CALProjectImageSet class
DLP = CALProjectImageSet(image_set_obj,rot_vel,monitor_id,blank_when_paused);

% begin projecting images
DLP.startProjecting();



cd 'Examples';