classdef ReconObj
    
    properties
        reconstruction
        proj_params_used
        opt_params_used
    end
    
    methods
        function obj = ReconObj(reconstruction,proj_params_used,opt_params_used)
            obj.reconstruction = reconstruction;
            obj.proj_params_used = proj_params_used;
            obj.opt_params_used = opt_params_used;
        end
        

    end
end

