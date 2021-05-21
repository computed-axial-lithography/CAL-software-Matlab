classdef Projector3DParallel
    
    properties
        proj_params
        parallel
    end
    
    methods
        function obj = Projector3DParallel(proj_params,parallel)
            obj.proj_params = proj_params;
            obj.parallel = parallel;
        end
        

        function [b] = forward(obj,x)
            [nT,~,nZ] = size(x);
            
            b = zeros(nT,length(obj.proj_params.angles),nZ);
            
            if obj.parallel
                parfor z = 1:nZ
                    tmp_b = radon(x(:,:,z), obj.proj_params.angles);
                    tmp_b([1:size(tmp_b,1)/2-nT/2, size(tmp_b,1)/2+nT/2+1:end],:) = [];
                    b(:,:,z) = tmp_b;
            
                end
            else 
                for z = 1:nZ
                    tmp_b = radon(x(:,:,z), obj.proj_params.angles);
                    tmp_b([1:size(tmp_b,1)/2-nT/2, size(tmp_b,1)/2+nT/2+1:end],:) = [];
                    b(:,:,z) = tmp_b;
                end
            end
        end
        
        function [x] = backward(obj,b)
            [nT,~,nZ] = size(b);
            x = zeros(nT,nT,nZ);
            
            
            if obj.parallel
                parfor z = 1:nZ
                    x(:,:,z) = iradon(b(:,:,z), obj.proj_params.angles, 'none',nT);
                end        
            else
                for z = 1:nZ
                    x(:,:,z) = iradon(b(:,:,z), obj.proj_params.angles, 'none',nT);
                end
            end % end if parallel
            x = clipToCircle(x);
        end
    end
end

