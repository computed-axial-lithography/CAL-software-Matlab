classdef ProjObj
    
    properties
        projection
        proj_params_used
        opt_params_used
    end
    
    methods
        function obj = ProjObj(projection,proj_params_used,opt_params_used)
            obj.projection = projection;
            obj.proj_params_used = proj_params_used;
            obj.opt_params_used = opt_params_used;
        end
        

    end
end

