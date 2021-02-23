classdef ImageSetObj
    
    properties
        image_set
        image_params_used
        proj_params_used
        opt_params_used
    end
    
    methods
        function obj = ImageSetObj(image_set,image_params_used,proj_params_used,opt_params_used)
            obj.image_set = image_set;
            obj.image_params_used = image_params_used;
            obj.proj_params_used = proj_params_used;
            obj.opt_params_used = opt_params_used;
            
        end
        

    end
end

