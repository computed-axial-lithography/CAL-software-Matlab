function [ProjectorObj] = CALProjectorConstructor(target_obj,proj_params,parallel)

    if ~exist('parallel','var')
        parallel = 0;
    end

    if target_obj.dim == 2
        ProjectorObj = Projector2D(proj_params);
    elseif target_obj.dim == 3
        ProjectorObj = Projector3D(proj_params,parallel);
    end
    
    

end

