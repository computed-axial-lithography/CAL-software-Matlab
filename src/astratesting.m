% 
% data = target_obj.target;
% angles = linspace(0,359,360);
% 
% proj_geom = astra_create_proj_geom('parallel3d', 1, 1, 200, 200, deg2rad(angles));
% 
% y = size(data,2);
% x = size(data,1);
% z = size(data,3);
% vol_geom = astra_create_vol_geom(y,x,z);
% [id, projdata] = astra_create_sino3d_cuda(data, proj_geom, vol_geom);
% 
% 
% [id, volume] = astra_create_backprojection3d_cuda(projdata, proj_geom, vol_geom);

%%


clear all
close all

%%%%%%%%%%%%%  Projection generation and optimization  %%%%%%%%%%%%%
% set projection parameters
proj_params.angles = linspace(0,359,360);
proj_params.bit8 = 1;
proj_params.CUDA = 1;
proj_params.inclination_angle = 0;
proj_params.cone_angle = 0;

% set optimization parameters
opt_params.max_iter = 60;
opt_params.threshold = 0.8;
opt_params.learning_rate = 0.004;

verbose = 1;

% prepare the target
scalefactor = 2.5;
height = 8/scalefactor;

resolution = ceil(height/(0.0108*1.25));
stl_filename =  'truncatedoctahedroncells2x2x4_1010degtilt.stl';% acceptable inputs 'bear', 'thinker', 'octet', 'octahedron'
target_obj = CALPrepTarget(stl_filename,resolution,verbose);

% target_obj.target = padarray(target_obj.target,[0,0,40],0);

%%
% A = CALProjectorConstructor(target_obj,proj_params);
% b = A.forward(target_obj.target);
% figure;
% for i = 1:size(b,2)
%     imagesc(squeeze(b(:,i,:)))
%     pause(0.01)
% end

%%
% instantiate the optimization class
Opt = CALOptimize(target_obj,opt_params,proj_params,verbose);

% run the optimization
[proj_obj,recon_obj,Opt] = Opt.run();

%%


image_params.size_scale_factor = scalefactor;
image_params.rotate = 45;
image_params.image_width = 1920; % this parameter should be changed to match your projector image, default is 1920
image_params.image_height = 1080; % this parameter should be changed to match your projector image, default is 1080

C = CALCreateImageSet(proj_obj,image_params);

image_set_obj = C.run();
projection_set = image_set_obj.image_set;
figure;
imagesc(image_set_obj.image_set{1})

%%
% figure;
% for i = 1:size(b,2)
%     imagesc(squeeze(b(:,i,:)))
%     pause(0.01)
% end
% 
% %%
% figure;
% for i = 1:size(x,3)
%     imagesc(x(:,:,i))
%     pause(0.01)
% end