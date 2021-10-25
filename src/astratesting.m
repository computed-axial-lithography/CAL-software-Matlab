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


% A = CALProjectorConstructor(target_obj,proj_params);
% b = A.forward(target_obj.target);
% figure;
% for i = 1:size(b,2)
%     imagesc(squeeze(b(:,i,:)))
%     pause(0.01)
% end


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

%%
% save('G:\My Drive\Research\Glassomer\Prints\FresnelLens\proj.mat','proj_obj')
save('G:\My Drive\Research\Glassomer\Prints\FresnelLens\projectionset.mat','projection_set')
% save('G:\My Drive\Research\Glassomer\Prints\TripleVasculature\v3\imageset.mat','image_set_obj')
% save('G:\My Drive\Research\Glassomer\Prints\TripleVasculature\v3\recon.mat','recon_obj')

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