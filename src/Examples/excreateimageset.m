cd ..;
addpath('Examples')


image_params.size_scale_factor = 2;
image_params.invert_vert = 1;
image_params.intensity_scale_factor = 1;
image_params.t_offset = 0;
image_params.z_offset = 0;
image_params.array_num = 2;
image_params.array_offset = 350;
image_params.image_width = 1920;
image_params.image_height = 1080;

C = CALCreateImageSet(proj_obj,image_params);

image_set_obj = C.run();

Display.showImageSet(image_set_obj)

% Images may be saved also
% C.saveImages(image_set_obj,pwd,'.png');



% image_params.size_scale_factor = 3;
% image_params.invert_vert = 1;
% image_params.intensity_scale_factor = 1;
% image_params.t_offset = 0;
% image_params.z_offset = 100;
% image_params.array_num = 2;
% image_params.array_offset = 300;
% image_params.image_width = 1920;
% image_params.image_height = 1080;
% image_params.angles = linspace(0,179,180); % this parameter must be added 
% 
% C = CALCreateImageSet(optimized_projections,image_params); % Note: now a 3D matrix is in the place of the typical projection object
% 
% image_set_obj = C.run();
% 
% Display.showImageSet(image_set_obj)
% 
% % Images may be saved also
% % C.saveImages(image_set_obj,pwd,'.png');

cd 'Examples';
