function [ProjectorObj] = CALProjectorConstructor(target_obj,proj_params,parallel)

    if ~exist('parallel','var')
        parallel = 0;
    end
    
    if ~isfield(proj_params,'inclination_angle')
        proj_params.inclination_angle = 0;
    end     
    
    if ~isfield(proj_params,'CUDA') || proj_params.CUDA == 0
        if target_obj.dim == 2
            ProjectorObj = Projector2DParallel(proj_params);
        elseif target_obj.dim == 3
            ProjectorObj = Projector3DParallel(proj_params,parallel);
        end
    
    elseif proj_params.CUDA == 1
        assert(testAstra()==1)
        
        if ~isfield(proj_params,'cone_angle') || proj_params.cone_angle == 0
            ProjectorObj = Projector3DParallelCUDA(target_obj,proj_params);
        else
            ProjectorObj = Projector3DConeCUDA(target_obj,proj_params);
        end
    
    else
        error('CALProjectorConstructor failed because projector parameters not defined');
    end

end

