classdef Projector2D
    
    properties
        proj_params
    end
    
    methods
        function obj = Projector2D(proj_params)
            obj.proj_params = proj_params;

        end
        
        
        function [b] = forward(obj,target)
            x = target;
            [nT,~] = size(x);

            tmp_b = radon(x, obj.proj_params.angles);
            tmp_b([1:size(tmp_b,1)/2-nT/2, size(tmp_b,1)/2+nT/2+1:end],:) = [];
            b = tmp_b;
        end
        
        function [x] = backward(obj,proj)
            b = proj;
            [nT,~] = size(b);

            x = iradon(b, obj.proj_params.angles, 'none',nT);
            x = clipToCircle(x);
        end
    end
end

