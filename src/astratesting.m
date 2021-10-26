clear all
close all

%%%%%%%%%%%%%  Projection generation and optimization  %%%%%%%%%%%%%
% set projection parameters
proj_params.angles = linspace(0,359,360);
proj_params.bit8 = 0;
proj_params.CUDA = 1;
proj_params.inclination_angle = 15;
proj_params.cone_angle = 10;

% set optimization parameters
opt_params.max_iter = 10;
opt_params.threshold = 0.7;
opt_params.learning_rate = 0.01;

verbose = 1;

resolution = 120;
stl_filename =  'Examples\rect_prism.stl';% acceptable inputs 'bear', 'thinker', 'octet', 'octahedron'
target_obj = CALPrepTarget(stl_filename,resolution,verbose);

% target_obj.target = padarray(target_obj.target,[0,0,40],0);

% instantiate the optimization class
Opt = CALOptimize(target_obj,opt_params,proj_params,verbose);

% run the optimization
[proj_obj,recon_obj,Opt] = Opt.run();

%%
image_params.size_scale_factor = 1.0;
image_params.invert_vert = 0;
image_params.rotate = 45;
image_params.image_width = 1920; % this parameter should be changed to match your projector image, default is 1920
image_params.image_height = 1080; % this parameter should be changed to match your projector image, default is 1080
image_params.angles = linspace(0,359,360);

C = CALCreateImageSet(opt_proj,image_params);

image_set_obj = C.run();
projection_set = image_set_obj.image_set;
figure;
imagesc(image_set_obj.image_set{1})
