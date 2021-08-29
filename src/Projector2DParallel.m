classdef Projector2DParallel
    
    properties
        proj_params
    end
    
    methods
        function obj = Projector2DParallel(proj_params)
            obj.proj_params = proj_params;
            
            if ~isscalar(obj.proj_params.zero_constraint)
                obj.proj_params.proj_mask = obj.getProjMask(obj.proj_params.zero_constraint);
            end
        end
        
        function [b] = getProjMask(obj,fills)
            x = fills;
            [nT,~] = size(x);

            tmp_b = radon(x, obj.proj_params.angles);
            tmp_b([1:size(tmp_b,1)/2-nT/2, size(tmp_b,1)/2+nT/2+1:end],:) = [];
            b = logical(tmp_b);
        end
        
        function [b] = forward(obj,x)
            [nT,~] = size(x);

            tmp_b = radon(x, obj.proj_params.angles);
            tmp_b([1:size(tmp_b,1)/2-nT/2, size(tmp_b,1)/2+nT/2+1:end],:) = [];
            b = tmp_b;
            
            if ~isscalar(obj.proj_params.zero_constraint)
                b(obj.proj_params.proj_mask) = 0;
            end
        end
        
        function [x] = backward(obj,b)
            if ~isscalar(obj.proj_params.zero_constraint)
                b(obj.proj_params.proj_mask) = 0;
            end
            [nT,~] = size(b);

            x = iradon(b, obj.proj_params.angles, 'none',nT);
            x = clipToCircle(x);
        end
    end
end

