
data = target_obj.target;
angles = linspace(0,359,360);

proj_geom = astra_create_proj_geom('parallel3d', 1, 1, 200, 200, deg2rad(angles));

y = size(data,2);
x = size(data,1);
z = size(data,3);
vol_geom = astra_create_vol_geom(y,x,z);
[id, projdata] = astra_create_sino3d_cuda(data, proj_geom, vol_geom);


[id, volume] = astra_create_backprojection3d_cuda(projdata, proj_geom, vol_geom);

%%


clear all
close all

%%%%%%%%%%%%%  Projection generation and optimization  %%%%%%%%%%%%%
% set projection parameters
proj_params.angles = linspace(0,359,360);
proj_params.bit8 = 1;
proj_params.CUDA = 1;

% set optimization parameters
opt_params.max_iter = 50;
opt_params.threshold = 0.8;
opt_params.learning_rate = 0.005;

verbose = 1;

% prepare the target
resolution = 300;
stl_filename = loadExStlFilename('bear'); % acceptable inputs 'bear', 'thinker', 'octet', 'octahedron'
target_obj = CALPrepTarget(stl_filename,resolution,verbose);

% instantiate the optimization class
Opt = CALOptimize(target_obj,opt_params,proj_params,verbose);

%%
% run the optimization
[proj_obj,recon_obj,Opt] = Opt.run();



%%
figure;
for i = 1:size(projdata,2)
    imagesc(squeeze(projdata(:,i,:)))
    pause(0.01)
end

%%
figure;
for i = 1:size(volume,3)
    imagesc(volume(:,:,i))
    pause(0.01)
end