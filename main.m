% based on 2D matrix example on 
% https://cal-software-matlab.readthedocs.io/en/latest/sec_examples.html

%%
% function main()
%%
clear all
close all

import src.*
import src.STL_read_bin.*
import src.autoArrangeFigures_bin.*
import src.imshow_3D_bin.*
import src.colormaps_bin.*

% set projection parameters
proj_params.angles = linspace(0,179,180);
proj_params.bit8 = 1;

% set optimization parameters
opt_params.max_iter = 1;
opt_params.threshold = 0.8;
opt_params.learning_rate = 0.005;

verbose = 0;

% prepare the target
resolution = 140;
stl_filename = loadExStlFilename('bear'); % acceptable inputs 'bear', 'thinker', 'octet', 'octahedron'
target_obj = CALPrepTarget(stl_filename,resolution,verbose);
fprintf('\ntarget prepped\n')

% instantiate the optimization class
Opt = CALOptimize(target_obj,opt_params,proj_params,verbose);

% run the optimization
[proj_obj,recon_obj,Opt] = Opt.run();
fprintf('\noptimized\n')
%%
image_params.size_scale_factor = 2;
image_params.invert_vert = 1;
image_params.z_offset = 100;
image_params.array_num = 2;
image_params.array_offset = 350;
image_params.image_width = 2716; % this parameter MUST be changed to match your projector image width for proper scaling
image_params.image_height = 1528; % this parameter MUST be changed to match your projector image height for proper scaling

C = CALCreateImageSet(proj_obj,image_params);

image_set_obj = C.run();
fprintf('\nImage Set created\n')

% Display.showImageSet(image_set_obj)

% Images may be saved also
% C.saveImages(image_set_obj,pwd,'.png');
%%
% set the rotation velocity in deg/s
rot_vel = 24;

% initialize the CALProjectImageSet class, this basic example assumes the projector is connected
% to the highest monitor number (e.g. if there are 2 monitors, it assumes projector is connected to
% monitor #2)
DLP = CALProjectImageSet(image_set_obj,rot_vel);

DLP.motorsyncinit(55941090,90);

% begin projecting images
DLP.startProjecting(0);
%%
% end
