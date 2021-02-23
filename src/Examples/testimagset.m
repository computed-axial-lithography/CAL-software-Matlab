image_params.size_scale_factor = 1.5;
image_params.rotate = 0;
image_params.invert_vert = 0;
image_params.intensity_scale_factor = 1;
image_params.t_offset = 400;
image_params.z_offset = 100;
image_params.array_num = 3;
image_params.array_offset = 250;

C = CALCreateImageSet(proj_obj,image_params);


image_set_obj = C.run();

Display.showImageSet(image_set_obj)

% C.saveImages(image_set_obj,pwd,'.png');


% CALCreateImageSet.saveImages(image_set_obj,pwd,'.png');



