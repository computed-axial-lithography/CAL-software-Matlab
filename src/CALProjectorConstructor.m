function [ProjectorObj] = CALProjectorConstructor(target_obj,proj_params,parallel)

    if ~exist('parallel','var')
        parallel = 0;
    end
    
    if ~isfield(proj_params,'inclination_angle')
        proj_params.inclination_angle = 0;
    end     
    
    if target_obj.dim == 2
        ProjectorObj = Projector2D(proj_params);
    elseif target_obj.dim == 3
        ProjectorObj = Projector3D(proj_params,parallel);
    end
    
    if proj_params.CUDA == 1
        assert(testAstra()==1)
        
        if proj_params.inclination_angle ~= 0 
            ProjectorObj = Projector3DCUDATomosynthesis(target_obj,proj_params);
        else
            ProjectorObj = Projector3DCUDA(target_obj,proj_params);
        end
        
    end

end

